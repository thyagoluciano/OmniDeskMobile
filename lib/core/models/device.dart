class TrustedDevice {
  final String id;
  final String name;
  final String token;
  final String lastAddr;
  final DateTime lastSeen;
  final bool isOnline;

  TrustedDevice({
    required this.id,
    required this.name,
    required this.token,
    required this.lastAddr,
    required this.lastSeen,
    this.isOnline = false,
  });

  TrustedDevice copyWith({
    String? id,
    String? name,
    String? token,
    String? lastAddr,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return TrustedDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      token: token ?? this.token,
      lastAddr: lastAddr ?? this.lastAddr,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  factory TrustedDevice.fromJson(Map<String, dynamic> json) {
    return TrustedDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Computador',
      token: json['token'] as String? ?? '',
      lastAddr: json['last_addr'] as String? ?? '',
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'] as String) ?? DateTime.now()
          : DateTime.now(),
      isOnline: json['is_online'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'token': token,
      'last_addr': lastAddr,
      'last_seen': lastSeen.toIso8601String(),
    };
  }
}
