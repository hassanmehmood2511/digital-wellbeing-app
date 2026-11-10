package com.example.digital_wellbeing_app

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * Behtar's screen-time bridge.
 *
 * Exposes Android's UsageStatsManager to Flutter on the "behtar/usage_stats"
 * channel. Android has no runtime popup for this permission: the user turns on
 * "Usage access" for Behtar in system settings, which [openUsageSettings] opens.
 */
class MainActivity : FlutterActivity() {

    private val channelName = "behtar/usage_stats"
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasUsagePermission())
                    "openSettings" -> {
                        openUsageSettings()
                        result.success(null)
                    }
                    "getTimeZone" -> result.success(java.util.TimeZone.getDefault().id)
                    "openNotificationSettings" -> {
                        openNotificationSettings()
                        result.success(null)
                    }
                    "getDailyUsage" -> {
                        val days = (call.argument<Int>("days") ?: 7).coerceIn(1, 30)
                        if (!hasUsagePermission()) {
                            result.error("NO_PERMISSION", "Usage access is not granted", null)
                            return@setMethodCallHandler
                        }
                        // Reading events can take a moment: do it off the UI thread.
                        Thread {
                            try {
                                val data = dailyUsage(days)
                                mainHandler.post { result.success(data) }
                            } catch (e: Exception) {
                                mainHandler.post { result.error("USAGE_ERROR", e.message, null) }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        }
        if (mode == AppOpsManager.MODE_DEFAULT) {
            return checkCallingOrSelfPermission(android.Manifest.permission.PACKAGE_USAGE_STATS) ==
                PackageManager.PERMISSION_GRANTED
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageSettings() {
        // Many phones open Behtar's own switch directly with the package URI;
        // the rest show the list of apps, so fall back to that.
        try {
            startActivity(
                Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    .setData(Uri.fromParts("package", packageName, null)),
            )
        } catch (e: Exception) {
            try {
                startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
            } catch (e2: Exception) {
                startActivity(Intent(Settings.ACTION_SETTINGS))
            }
        }
    }

    private fun openNotificationSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.fromParts("package", packageName, null))
        }
        try {
            startActivity(intent)
        } catch (e: Exception) {
            startActivity(Intent(Settings.ACTION_SETTINGS))
        }
    }

    /**
     * One entry per day (today first), each with the launchable apps used that
     * day: [{date: "yyyy-MM-dd", apps: [{package, label, minutes}]}].
     */
    private fun dailyUsage(days: Int): List<Map<String, Any>> {
        val format = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        val dayStart = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val now = System.currentTimeMillis()
        val labelCache = HashMap<String, String?>()
        val output = ArrayList<Map<String, Any>>()

        for (i in 0 until days) {
            val start = dayStart.timeInMillis
            val nextDay = (dayStart.clone() as Calendar).apply { add(Calendar.DAY_OF_YEAR, 1) }
            val end = minOf(nextDay.timeInMillis, now)

            val apps = ArrayList<Map<String, Any>>()
            for ((pkg, millis) in foregroundTime(start, end)) {
                if (pkg == packageName) continue
                val minutes = (millis / 60000L).toInt()
                if (minutes < 1) continue
                val label = labelCache.getOrPut(pkg) { launchableLabel(pkg) } ?: continue
                apps.add(mapOf("package" to pkg, "label" to label, "minutes" to minutes))
            }
            output.add(mapOf("date" to format.format(dayStart.time), "apps" to apps))
            dayStart.add(Calendar.DAY_OF_YEAR, -1)
        }
        return output
    }

    /** Milliseconds each package spent in the foreground between start and end. */
    private fun foregroundTime(start: Long, end: Long): Map<String, Long> {
        val manager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = manager.queryEvents(start, end)
        val event = UsageEvents.Event()
        val openCount = HashMap<String, Int>()
        val openSince = HashMap<String, Long>()
        val seen = HashSet<String>()
        val totals = HashMap<String, Long>()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName ?: continue
            when (event.eventType) {
                RESUMED -> {
                    val count = openCount[pkg] ?: 0
                    if (count == 0) openSince[pkg] = event.timeStamp
                    openCount[pkg] = count + 1
                    seen.add(pkg)
                }
                PAUSED -> {
                    val count = openCount[pkg] ?: 0
                    if (count > 0) {
                        openCount[pkg] = count - 1
                        if (count == 1) {
                            val since = openSince.remove(pkg) ?: event.timeStamp
                            totals[pkg] = (totals[pkg] ?: 0L) + (event.timeStamp - since)
                        }
                    } else if (!seen.contains(pkg)) {
                        // App was already open when the day started.
                        totals[pkg] = (totals[pkg] ?: 0L) + (event.timeStamp - start)
                    }
                    seen.add(pkg)
                }
            }
        }
        // Apps still open at the end of the range.
        for ((pkg, since) in openSince) {
            if ((openCount[pkg] ?: 0) > 0) {
                totals[pkg] = (totals[pkg] ?: 0L) + (end - since)
            }
        }
        return totals
    }

    /** App name for apps that appear in the launcher; null for system services. */
    private fun launchableLabel(pkg: String): String? {
        return try {
            if (packageManager.getLaunchIntentForPackage(pkg) == null) return null
            val info = packageManager.getApplicationInfo(pkg, 0)
            packageManager.getApplicationLabel(info).toString()
        } catch (e: Exception) {
            null
        }
    }

    companion object {
        // UsageEvents.Event.ACTIVITY_RESUMED / ACTIVITY_PAUSED (same values as the
        // older MOVE_TO_FOREGROUND / MOVE_TO_BACKGROUND, so this works on all versions).
        private const val RESUMED = 1
        private const val PAUSED = 2
    }
}
