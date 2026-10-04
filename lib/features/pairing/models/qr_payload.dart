import 'dart:convert';

class QRPairPayload {
  final int v;
  final String id;
  final String name;
  final List<String> addrs;
  final String pin;

  QRPairPayload({
    required this.v,
    required this.id,
    required this.name,
    required this.addrs,
    required this.pin,
  });

  static QRPairPayload? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw.trim());
      if (decoded is! Map<String, dynamic>) return null;

      final id = decoded['id'] as String?;
      final pin = decoded['pin']?.toString();
      if (id == null || pin == null || pin.isEmpty) return null;

      final name = decoded['name'] as String? ?? 'Computador';
      final v = decoded['v'] as int? ?? 1;

      List<String> addrs = [];
      if (decoded['addrs'] is List) {
        addrs = (decoded['addrs'] as List).map((e) => e.toString()).toList();
      } else if (decoded['addr'] != null) {
        addrs = [decoded['addr'].toString()];
      }

      if (addrs.isEmpty) return null;

      return QRPairPayload(
        v: v,
        id: id,
        name: name,
        addrs: addrs,
        pin: pin,
      );
    } catch (_) {
      return null;
    }
  }
}
