import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/device.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keyDeviceId = 'omnidesk_device_id';
  static const String _keyDeviceName = 'omnidesk_device_name';
  static const String _keyTrustedDevices = 'omnidesk_trusted_devices';
  static const String _keyAutoSync = 'omnidesk_auto_sync_clipboard';

  String? _cachedDeviceId;
  String? _cachedDeviceName;

  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    String? id = await _storage.read(key: _keyDeviceId);
    if (id == null || id.isEmpty) {
      final rand = Random.secure();
      final bytes = List<int>.generate(8, (_) => rand.nextInt(256));
      final hexStr = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      id = 'mob-$hexStr';
      await _storage.write(key: _keyDeviceId, value: id);
    }
    _cachedDeviceId = id;
    return id;
  }

  Future<String> getDeviceName() async {
    if (_cachedDeviceName != null) return _cachedDeviceName!;
    String? name = await _storage.read(key: _keyDeviceName);
    if (name == null || name.isEmpty) {
      name = 'Smartphone OmniDesk';
      await _storage.write(key: _keyDeviceName, value: name);
    }
    _cachedDeviceName = name;
    return name;
  }

  Future<void> setDeviceName(String name) async {
    _cachedDeviceName = name;
    await _storage.write(key: _keyDeviceName, value: name);
  }

  Future<bool> isAutoSyncEnabled() async {
    final val = await _storage.read(key: _keyAutoSync);
    return val != 'false'; // Default to true
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    await _storage.write(key: _keyAutoSync, value: enabled.toString());
  }

  Future<List<TrustedDevice>> getTrustedDevices() async {
    final raw = await _storage.read(key: _keyTrustedDevices);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => TrustedDevice.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTrustedDevice(TrustedDevice device) async {
    final devices = await getTrustedDevices();
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index >= 0) {
      devices[index] = device;
    } else {
      devices.add(device);
    }
    final encoded = jsonEncode(devices.map((d) => d.toJson()).toList());
    await _storage.write(key: _keyTrustedDevices, value: encoded);
  }

  Future<void> removeTrustedDevice(String id) async {
    final devices = await getTrustedDevices();
    devices.removeWhere((d) => d.id == id);
    final encoded = jsonEncode(devices.map((d) => d.toJson()).toList());
    await _storage.write(key: _keyTrustedDevices, value: encoded);
  }
}
