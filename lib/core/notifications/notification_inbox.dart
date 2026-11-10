import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/backend.dart';

/// Kind of notification, used for the icon and where tapping it leads.
enum InboxType { habit, checkIn, tip, screenTime, system }

class InboxItem {
  const InboxItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });

  final String id;
  final InboxType type;
  final String title;
  final String body;
  final DateTime time;
  final bool read;

  InboxItem copyWith({bool? read}) => InboxItem(
    id: id,
    type: type,
    title: title,
    body: body,
    time: time,
    read: read ?? this.read,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'body': body,
    'time': time.millisecondsSinceEpoch,
    'read': read,
  };

  static InboxItem? fromJson(Map<String, dynamic> json) {
    try {
      return InboxItem(
        id: json['id'] as String,
        type: InboxType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => InboxType.system,
        ),
        title: json['title'] as String,
        body: json['body'] as String,
        time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
        read: json['read'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }
}

/// History of notifications shown on this phone (per signed-in user).
///
/// Immediate notifications are added when shown. Scheduled reminders are kept
/// as "pending" and move into the history once their time has passed, because
/// Android delivers them while the app may be closed.
class NotificationInbox extends ChangeNotifier {
  NotificationInbox._();

  static final NotificationInbox instance = NotificationInbox._();

  static const int _maxItems = 100;

  final List<InboxItem> _items = [];
  List<InboxItem> _pending = [];
  String? _loadedFor;

  List<InboxItem> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((i) => !i.read).length;

  String get _owner => Backend.userId ?? 'guest';
  String get _itemsKey => 'inbox_items_$_owner';
  String get _pendingKey => 'inbox_pending_$_owner';

  /// Loads the current user's history and moves any delivered reminders in.
  Future<void> refresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_loadedFor != _owner) {
        _items
          ..clear()
          ..addAll(_decode(prefs.getString(_itemsKey)));
        _pending = _decode(prefs.getString(_pendingKey));
        _loadedFor = _owner;
      }
      _harvest();
      _welcomeOnce(prefs);
      await _save(prefs);
    } catch (error) {
      debugPrint('Inbox refresh failed: $error');
    }
    notifyListeners();
  }

  /// Records a notification that was just shown.
  Future<void> add({
    required InboxType type,
    required String title,
    required String body,
  }) async {
    await refresh();
    final now = DateTime.now();
    _items.insert(
      0,
      InboxItem(
        id: '${type.name}@${now.millisecondsSinceEpoch}',
        type: type,
        title: title,
        body: body,
        time: now,
      ),
    );
    _trim();
    await _persist();
  }

  /// Replaces the list of upcoming scheduled reminders.
  Future<void> setPending(List<InboxItem> upcoming) async {
    await refresh();
    _pending = List.of(upcoming);
    await _persist();
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(read: true);
    }
    await _persist();
  }

  Future<void> markRead(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1 || _items[index].read) return;
    _items[index] = _items[index].copyWith(read: true);
    await _persist();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persist();
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
  }

  /// Drops upcoming reminders for the user whose inbox is loaded (used on
  /// sign out, when those reminders are cancelled and will never arrive).
  Future<void> discardPending() async {
    final owner = _loadedFor;
    _pending = [];
    if (owner == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('inbox_pending_$owner', '[]');
    } catch (_) {}
  }

  /// Forget the in-memory copy (used on sign out); saved data stays per user.
  void reset() {
    _items.clear();
    _pending = [];
    _loadedFor = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------

  void _harvest() {
    final now = DateTime.now();
    final delivered = _pending.where((p) => !p.time.isAfter(now)).toList();
    if (delivered.isEmpty) return;
    _pending.removeWhere((p) => !p.time.isAfter(now));
    final known = _items.map((i) => i.id).toSet();
    for (final item in delivered) {
      if (!known.contains(item.id)) _items.add(item);
    }
    _items.sort((a, b) => b.time.compareTo(a.time));
    _trim();
  }

  void _welcomeOnce(SharedPreferences prefs) {
    if (_owner == 'guest') return;
    final key = 'inbox_welcomed_$_owner';
    if (prefs.getBool(key) == true) return;
    prefs.setBool(key, true);
    if (_items.isNotEmpty) return;
    final now = DateTime.now();
    _items.add(
      InboxItem(
        id: 'welcome@${now.millisecondsSinceEpoch}',
        type: InboxType.system,
        title: 'Welcome to Behtar 🌿',
        body:
            'Your reminders, tips and screen-time alerts will appear here. '
            'Choose what you get in Profile › Settings › Notifications.',
        time: now,
      ),
    );
  }

  void _trim() {
    if (_items.length > _maxItems) {
      _items.removeRange(_maxItems, _items.length);
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _save(prefs);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _save(SharedPreferences prefs) async {
    await prefs.setString(
      _itemsKey,
      jsonEncode(_items.map((i) => i.toJson()).toList()),
    );
    await prefs.setString(
      _pendingKey,
      jsonEncode(_pending.map((i) => i.toJson()).toList()),
    );
  }

  static List<InboxItem> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => InboxItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .whereType<InboxItem>()
          .toList();
    } catch (_) {
      return [];
    }
  }
}
