import 'dart:convert';
import 'package:crypto/crypto.dart';

class AntiEcho {
  static final AntiEcho _instance = AntiEcho._internal();
  factory AntiEcho() => _instance;
  AntiEcho._internal();

  final Map<String, DateTime> _cache = {};

  String hashText(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool isEcho(String text) {
    prune();
    final h = hashText(text);
    final exp = _cache[h];
    if (exp == null) return false;
    return DateTime.now().isBefore(exp);
  }

  void record(String text, {Duration ttl = const Duration(seconds: 10)}) {
    prune();
    final h = hashText(text);
    _cache[h] = DateTime.now().add(ttl);
  }

  void prune() {
    final now = DateTime.now();
    _cache.removeWhere((_, exp) => now.isAfter(exp));
  }
}
