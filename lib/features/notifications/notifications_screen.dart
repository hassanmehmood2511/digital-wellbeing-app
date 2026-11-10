import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/notifications/notification_inbox.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatters.dart';

/// Recent and earlier notifications (reminders, tips, screen-time alerts).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({this.onOpenTab, super.key});

  /// Opens a bottom-navigation tab (e.g. Habits) when a notification is tapped.
  final ValueChanged<int>? onOpenTab;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationInbox _inbox = NotificationInbox.instance;

  @override
  void initState() {
    super.initState();
    _inbox.refresh();
  }

  @override
  void dispose() {
    // Everything the user has seen here counts as read.
    _inbox.markAllRead();
    super.dispose();
  }

  int? _tabFor(InboxType type) => switch (type) {
    InboxType.habit => 1,
    InboxType.checkIn => 0,
    InboxType.screenTime => 4,
    InboxType.tip || InboxType.system => null,
  };

  void _open(InboxItem item) {
    _inbox.markRead(item.id);
    final tab = _tabFor(item.type);
    if (tab != null && widget.onOpenTab != null) {
      widget.onOpenTab!(tab);
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text(
          'This removes your notification history from this phone. '
          'Upcoming reminders are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _inbox.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _inbox,
      builder: (context, _) {
        final items = _inbox.items;
        final cutoff = DateTime.now().subtract(const Duration(hours: 24));
        final recent = items.where((i) => i.time.isAfter(cutoff)).toList();
        final earlier = items.where((i) => !i.time.isAfter(cutoff)).toList();

        return Scaffold(
          backgroundColor: BehtarColors.background,
          appBar: AppBar(
            title: const Text('Notifications'),
            backgroundColor: BehtarColors.background,
            elevation: 0,
            actions: [
              if (_inbox.unreadCount > 0)
                IconButton(
                  tooltip: 'Mark all as read',
                  icon: const Icon(Icons.done_all_rounded),
                  onPressed: _inbox.markAllRead,
                ),
              if (items.isNotEmpty)
                IconButton(
                  tooltip: 'Clear all',
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: _confirmClear,
                ),
            ],
          ),
          body: RefreshIndicator(
            color: BehtarColors.primary,
            onRefresh: _inbox.refresh,
            child: items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 120), _EmptyState()],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      BehtarSpacing.base,
                      BehtarSpacing.sm,
                      BehtarSpacing.base,
                      BehtarSpacing.xl,
                    ),
                    children: [
                      if (recent.isNotEmpty) ...[
                        const _SectionTitle('Recent'),
                        for (final item in recent) _buildTile(item),
                      ],
                      if (earlier.isNotEmpty) ...[
                        const SizedBox(height: BehtarSpacing.md),
                        const _SectionTitle('Earlier'),
                        for (final item in earlier) _buildTile(item),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTile(InboxItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _inbox.remove(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: BehtarSpacing.lg),
        margin: const EdgeInsets.only(bottom: BehtarSpacing.sm),
        decoration: BoxDecoration(
          color: BehtarColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(BehtarRadii.card),
        ),
        child: const Icon(Icons.delete_outline, color: BehtarColors.error),
      ),
      child: _NotificationTile(item: item, onTap: () => _open(item)),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final InboxItem item;
  final VoidCallback onTap;

  static IconData _icon(InboxType type) => switch (type) {
    InboxType.habit => Icons.task_alt_rounded,
    InboxType.checkIn => Icons.wb_sunny_outlined,
    InboxType.tip => Icons.lightbulb_outline_rounded,
    InboxType.screenTime => Icons.hourglass_bottom_rounded,
    InboxType.system => Icons.notifications_none_rounded,
  };

  static String _timeLabel(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    final today = dateOnly(now);
    final day = dateOnly(time);
    final clock = TimeOfDay.fromDateTime(time).format(context);
    if (day == today) return 'Today, $clock';
    if (today.difference(day).inDays == 1) return 'Yesterday, $clock';
    if (today.difference(day).inDays < 7) {
      return '${DateFormat.E().format(time)}, $clock';
    }
    return DateFormat('d MMM').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: BehtarSpacing.sm),
      child: Material(
        color: item.read ? BehtarColors.surface : BehtarColors.mint,
        borderRadius: BorderRadius.circular(BehtarRadii.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(BehtarRadii.card),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(BehtarSpacing.base),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BehtarRadii.card),
              border: Border.all(color: BehtarColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.read ? BehtarColors.mint : BehtarColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon(item.type),
                    color: BehtarColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: BehtarSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: item.read
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: BehtarColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!item.read)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(
                                left: BehtarSpacing.sm,
                                top: 6,
                              ),
                              decoration: const BoxDecoration(
                                color: BehtarColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: BehtarColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _timeLabel(context, item.time),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: BehtarColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: BehtarSpacing.sm,
        top: BehtarSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: BehtarColors.textPrimary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BehtarSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: BehtarColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: BehtarColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: BehtarSpacing.base),
          Text(
            'You’re all caught up',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: BehtarSpacing.xs),
          Text(
            'Reminders, tips and screen-time alerts will show up here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: BehtarColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
