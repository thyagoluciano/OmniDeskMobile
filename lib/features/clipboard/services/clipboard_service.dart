import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/anti_echo/anti_echo.dart';
import '../../../core/models/device.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../transfers/models/transfer_item.dart';
import '../../transfers/services/transfer_service.dart';

class ClipboardService {
  static final ClipboardService _instance = ClipboardService._internal();
  factory ClipboardService() => _instance;
  ClipboardService._internal();

  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();
  final AntiEcho _antiEcho = AntiEcho();
  final TransferService _transfers = TransferService();

  Future<bool> sendCurrentClipboardToDevice(TrustedDevice device) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return false;

    _antiEcho.record(text);
    final ok = await _api.sendClipboard(device, text);
    if (ok) {
      _transfers.addItem(
        TransferItem(
          id: 'clip-${DateTime.now().millisecondsSinceEpoch}',
          type: TransferType.text,
          direction: TransferDirection.outgoing,
          content: text,
          deviceName: device.name,
          timestamp: DateTime.now(),
          sizeBytes: utf8.encode(text).length,
        ),
      );
    }
    return ok;
  }

  Future<void> checkAndSyncOnResume() async {
    final autoSync = await _storage.isAutoSyncEnabled();
    if (!autoSync) return;

    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;

    if (_antiEcho.isEcho(text)) return;
    _antiEcho.record(text);

    final trusted = await _storage.getTrustedDevices();
    for (final dev in trusted) {
      _api.sendClipboard(dev, text).then((ok) {
        if (ok) {
          _transfers.addItem(
            TransferItem(
              id: 'clip-${DateTime.now().millisecondsSinceEpoch}',
              type: TransferType.text,
              direction: TransferDirection.outgoing,
              content: text,
              deviceName: dev.name,
              timestamp: DateTime.now(),
              sizeBytes: utf8.encode(text).length,
            ),
          );
        }
      });
    }
  }
}
