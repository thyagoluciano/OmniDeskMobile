enum TransferType { text, photo, file }
enum TransferDirection { incoming, outgoing }

class TransferItem {
  final String id;
  final TransferType type;
  final TransferDirection direction;
  final String content; // Text snippet or local file path
  final String fileName;
  final String deviceName;
  final DateTime timestamp;
  final int sizeBytes;

  TransferItem({
    required this.id,
    required this.type,
    required this.direction,
    required this.content,
    this.fileName = '',
    required this.deviceName,
    required this.timestamp,
    this.sizeBytes = 0,
  });

  String get formattedSize {
    if (sizeBytes <= 0) return '';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
