import 'package:flutter_test/flutter_test.dart';
import 'package:omnidesk_mobile/core/anti_echo/anti_echo.dart';
import 'package:omnidesk_mobile/core/models/device.dart';
import 'package:omnidesk_mobile/features/pairing/models/qr_payload.dart';
import 'package:omnidesk_mobile/features/transfers/models/transfer_item.dart';
import 'package:omnidesk_mobile/features/transfers/services/transfer_service.dart';

void main() {
  group('QRPairPayload Tests', () {
    test('Parse valid QR Code JSON payload', () {
      const jsonStr = '''
      {
        "v": 1,
        "id": "desk-macbook-pro",
        "name": "MacBook Pro de Thyago",
        "addrs": ["192.168.1.15:24850"],
        "pin": "849201"
      }
      ''';

      final payload = QRPairPayload.tryParse(jsonStr);
      expect(payload, isNotNull);
      expect(payload!.id, 'desk-macbook-pro');
      expect(payload.name, 'MacBook Pro de Thyago');
      expect(payload.pin, '849201');
      expect(payload.addrs.length, 1);
      expect(payload.addrs[0], '192.168.1.15:24850');
    });

    test('Parse invalid JSON returns null', () {
      expect(QRPairPayload.tryParse('invalid-non-json'), isNull);
      expect(QRPairPayload.tryParse('{"id": "no-pin"}'), isNull);
      expect(QRPairPayload.tryParse('{"pin": "123456"}'), isNull);
    });
  });

  group('AntiEcho Engine Tests', () {
    test('Deduplicates identical text within TTL', () {
      final antiEcho = AntiEcho();
      const text = 'https://omnidesk.local/download';

      expect(antiEcho.isEcho(text), isFalse);

      antiEcho.record(text);
      expect(antiEcho.isEcho(text), isTrue);

      // Different text is not considered an echo
      expect(antiEcho.isEcho('outro texto'), isFalse);
    });
  });

  group('TransferService Tests', () {
    test('Records incoming and outgoing transfer events', () {
      final transfers = TransferService();
      transfers.clear();

      expect(transfers.items.length, 0);

      transfers.addItem(
        TransferItem(
          id: 'test-1',
          type: TransferType.text,
          direction: TransferDirection.incoming,
          content: 'Mensagem de teste',
          deviceName: 'MacBook Pro',
          timestamp: DateTime.now(),
        ),
      );

      expect(transfers.items.length, 1);
      expect(transfers.items[0].content, 'Mensagem de teste');
      expect(transfers.items[0].direction, TransferDirection.incoming);

      transfers.addItem(
        TransferItem(
          id: 'test-2',
          type: TransferType.photo,
          direction: TransferDirection.outgoing,
          content: '/path/to/photo.jpg',
          fileName: 'photo.jpg',
          deviceName: 'MacBook Pro',
          timestamp: DateTime.now(),
          sizeBytes: 1024 * 1024 * 3, // 3MB
        ),
      );

      expect(transfers.items.length, 2);
      expect(transfers.items[0].formattedSize, '3.0 MB');
    });
  });

  group('TrustedDevice Model Tests', () {
    test('Serialization and deserialization', () {
      final dev = TrustedDevice(
        id: 'desk-1',
        name: 'Linux Workstation',
        token: 'secret-token-abc',
        lastAddr: '192.168.1.100:24850',
        lastSeen: DateTime.parse('2026-10-03T21:00:00Z'),
        isOnline: true,
      );

      final jsonMap = dev.toJson();
      expect(jsonMap['id'], 'desk-1');
      expect(jsonMap['name'], 'Linux Workstation');

      final reconstructed = TrustedDevice.fromJson(jsonMap);
      expect(reconstructed.id, dev.id);
      expect(reconstructed.name, dev.name);
      expect(reconstructed.token, dev.token);
      expect(reconstructed.lastAddr, dev.lastAddr);
    });
  });
}
