import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/device.dart';
import '../../../core/network/api_client.dart';
import '../models/transfer_item.dart';
import 'transfer_service.dart';

class FileTransferService {
  static final FileTransferService _instance = FileTransferService._internal();
  factory FileTransferService() => _instance;
  FileTransferService._internal();

  final ApiClient _api = ApiClient();
  final TransferService _transfers = TransferService();
  final ImagePicker _picker = ImagePicker();

  Future<int> pickAndSendPhotos(
    TrustedDevice target, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final images = await _picker.pickMultiImage();
    if (images.isEmpty) return 0;

    int successCount = 0;
    for (final img in images) {
      final file = File(img.path);
      final size = await file.length();
      final ok = await _api.uploadFile(
        target,
        img.path,
        onProgress: onProgress,
      );
      if (ok) {
        successCount++;
        _transfers.addItem(
          TransferItem(
            id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
            type: TransferType.photo,
            direction: TransferDirection.outgoing,
            content: img.path,
            fileName: img.name,
            deviceName: target.name,
            timestamp: DateTime.now(),
            sizeBytes: size,
          ),
        );
      }
    }
    return successCount;
  }

  Future<int> pickAndSendFiles(
    TrustedDevice target, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return 0;

    int successCount = 0;
    for (final platformFile in files) {
      final path = platformFile.path;
      if (path == null) continue;

      final ok = await _api.uploadFile(
        target,
        path,
        onProgress: onProgress,
      );
      if (ok) {
        successCount++;
        _transfers.addItem(
          TransferItem(
            id: 'file-${DateTime.now().millisecondsSinceEpoch}',
            type: TransferType.file,
            direction: TransferDirection.outgoing,
            content: path,
            fileName: platformFile.name,
            deviceName: target.name,
            timestamp: DateTime.now(),
            sizeBytes: platformFile.lengthSync() ?? 0,
          ),
        );
      }
    }
    return successCount;
  }
}
