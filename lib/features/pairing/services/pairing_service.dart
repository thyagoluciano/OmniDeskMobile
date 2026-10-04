import 'package:omnidesk_mobile/core/models/device.dart';
import 'package:omnidesk_mobile/core/network/api_client.dart';
import 'package:omnidesk_mobile/core/storage/storage_service.dart';
import '../models/qr_payload.dart';

class PairingService {
  static final PairingService _instance = PairingService._internal();
  factory PairingService() => _instance;
  PairingService._internal();

  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  Future<TrustedDevice> pairWithQRPayload(
    QRPairPayload payload, {
    String localListenAddr = '',
  }) async {
    dynamic lastError;
    for (final addr in payload.addrs) {
      try {
        final result = await _api.redeemQRPairing(
          targetAddr: addr,
          pin: payload.pin,
          localListenAddr: localListenAddr,
        );

        final token = result['auth_token'] as String;
        final devName = (result['device_name'] as String?) ?? payload.name;
        final devId = (result['device_id'] as String?) ?? payload.id;

        final device = TrustedDevice(
          id: devId,
          name: devName,
          token: token,
          lastAddr: addr,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        await _storage.saveTrustedDevice(device);
        return device;
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception('Não foi possível conectar em nenhum endereço do dispositivo: $lastError');
  }
}
