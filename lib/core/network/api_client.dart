import 'dart:io';
import 'package:dio/dio.dart';
import '../models/device.dart';
import '../storage/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(minutes: 10), // Large file upload support
    ),
  );

  final StorageService _storage = StorageService();

  Future<bool> checkStatus(String addr) async {
    try {
      final resp = await _dio.get('http://$addr/api/v1/status');
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> redeemQRPairing({
    required String targetAddr,
    required String pin,
    required String localListenAddr,
  }) async {
    final devId = await _storage.getDeviceId();
    final devName = await _storage.getDeviceName();

    final resp = await _dio.post(
      'http://$targetAddr/api/v1/pair/qr/redeem',
      data: {
        'pin': pin,
        'requester_id': devId,
        'requester_name': devName,
        'requester_addr': localListenAddr,
      },
    );

    if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
      return resp.data as Map<String, dynamic>;
    }
    throw Exception('Falha ao autenticar pareamento: ${resp.data}');
  }

  Future<bool> sendClipboard(TrustedDevice target, String text) async {
    final myId = await _storage.getDeviceId();
    try {
      final resp = await _dio.post(
        'http://${target.lastAddr}/api/v1/clipboard',
        data: {
          'sender_id': myId,
          'text': text,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-OmniDesk-Device-ID': myId,
            'X-OmniDesk-Token': target.token,
          },
        ),
      );
      return resp.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadFile(
    TrustedDevice target,
    String filePath, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $filePath');
    }

    final myId = await _storage.getDeviceId();
    final fileName = file.uri.pathSegments.last;
    final fileLength = await file.length();
    final fileStream = file.openRead();

    try {
      final resp = await _dio.post(
        'http://${target.lastAddr}/api/v1/files/upload',
        queryParameters: {'filename': fileName},
        data: fileStream,
        options: Options(
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Length': fileLength,
            'X-OmniDesk-Device-ID': myId,
            'X-OmniDesk-Token': target.token,
          },
        ),
        onSendProgress: onProgress,
      );
      return resp.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
