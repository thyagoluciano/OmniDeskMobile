import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../anti_echo/anti_echo.dart';
import '../models/device.dart';
import '../storage/storage_service.dart';
import '../../features/transfers/models/transfer_item.dart';
import '../../features/transfers/services/transfer_service.dart';

class LocalServer {
  static final LocalServer _instance = LocalServer._internal();
  factory LocalServer() => _instance;
  LocalServer._internal();

  HttpServer? _server;
  int _port = 24851;
  bool _isRunning = false;

  int get port => _port;
  bool get isRunning => _isRunning;

  final StorageService _storage = StorageService();
  final AntiEcho _antiEcho = AntiEcho();
  final TransferService _transfers = TransferService();

  Future<void> start({int port = 24851}) async {
    if (_isRunning) return;
    _port = port;

    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        _port,
        shared: true,
      );
      _isRunning = true;
      _server!.listen(_handleRequest);
    } catch (e) {
      // Fallback to ephemeral port if 24851 is in use
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        0,
        shared: true,
      );
      _port = _server!.port;
      _isRunning = true;
      _server!.listen(_handleRequest);
    }
  }

  Future<void> stop() async {
    _isRunning = false;
    await _server?.close(force: true);
    _server = null;
  }

  void _handleRequest(HttpRequest request) async {
    final path = request.uri.path;

    if (path == '/api/v1/status') {
      await _handleStatus(request);
      return;
    }

    // Authenticate all protected endpoints
    final deviceId = request.headers.value('x-omnidesk-device-id');
    final token = request.headers.value('x-omnidesk-token');

    final trusted = await _storage.getTrustedDevices();
    final peer = trusted.cast<TrustedDevice?>().firstWhere(
      (d) => d != null && d.id == deviceId && d.token == token,
      orElse: () => null,
    );

    if (peer == null) {
      request.response
        ..statusCode = HttpStatus.unauthorized
        ..write(jsonEncode({'error': 'unauthorized peer'}))
        ..close();
      return;
    }

    if (path == '/api/v1/clipboard' && request.method == 'POST') {
      await _handleClipboard(request, peer);
    } else if (path == '/api/v1/files/upload' && request.method == 'POST') {
      await _handleFileUpload(request, peer);
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..close();
    }
  }

  Future<void> _handleStatus(HttpRequest request) async {
    final devId = await _storage.getDeviceId();
    final devName = await _storage.getDeviceName();
    request.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({
        'device_id': devId,
        'device_name': devName,
        'status': 'online',
        'port': _port,
      }))
      ..close();
  }

  Future<void> _handleClipboard(HttpRequest request, TrustedDevice peer) async {
    try {
      final bodyStr = await utf8.decoder.bind(request).join();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;
      final text = body['text'] as String? ?? '';

      if (text.isNotEmpty) {
        if (!_antiEcho.isEcho(text)) {
          _antiEcho.record(text);
          await Clipboard.setData(ClipboardData(text: text));

          _transfers.addItem(
            TransferItem(
              id: 'clip-${DateTime.now().millisecondsSinceEpoch}',
              type: TransferType.text,
              direction: TransferDirection.incoming,
              content: text,
              deviceName: peer.name,
              timestamp: DateTime.now(),
              sizeBytes: utf8.encode(text).length,
            ),
          );
        }
      }

      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'status': 'ok'}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write(jsonEncode({'error': e.toString()}))
        ..close();
    }
  }

  Future<void> _handleFileUpload(HttpRequest request, TrustedDevice peer) async {
    try {
      final filenameQuery = request.uri.queryParameters['filename'];
      final rawName = filenameQuery != null && filenameQuery.isNotEmpty
          ? p.basename(filenameQuery)
          : 'file-${DateTime.now().millisecondsSinceEpoch}.bin';

      final docsDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(docsDir.path, 'OmniDesk'));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final targetPath = p.join(targetDir.path, rawName);
      final outFile = File(targetPath);
      final sink = outFile.openWrite();

      int bytesWritten = 0;
      await for (final chunk in request) {
        sink.add(chunk);
        bytesWritten += chunk.length;
      }
      await sink.flush();
      await sink.close();

      final ext = p.extension(rawName).toLowerCase();
      final isImage = ['.jpg', '.jpeg', '.png', '.heic', '.webp', '.gif'].contains(ext);

      _transfers.addItem(
        TransferItem(
          id: 'file-${DateTime.now().millisecondsSinceEpoch}',
          type: isImage ? TransferType.photo : TransferType.file,
          direction: TransferDirection.incoming,
          content: targetPath,
          fileName: rawName,
          deviceName: peer.name,
          timestamp: DateTime.now(),
          sizeBytes: bytesWritten,
        ),
      );

      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'status': 'received',
          'filename': rawName,
          'bytes_saved': bytesWritten,
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({'error': e.toString()}))
        ..close();
    }
  }
}
