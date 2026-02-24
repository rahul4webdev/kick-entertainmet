import 'dart:async';

class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry(this.data, Duration ttl) : expiresAt = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class ApiCacheManager {
  ApiCacheManager._();
  static final ApiCacheManager instance = ApiCacheManager._();

  final Map<String, _CacheEntry> _cache = {};
  Timer? _cleanupTimer;

  void init() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) => _cleanup());
  }

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T;
  }

  void set(String key, dynamic data, {Duration ttl = const Duration(minutes: 5)}) {
    _cache[key] = _CacheEntry(data, ttl);
  }

  void invalidate(String key) {
    _cache.remove(key);
  }

  void invalidatePrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  void clear() {
    _cache.clear();
  }

  void _cleanup() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}
