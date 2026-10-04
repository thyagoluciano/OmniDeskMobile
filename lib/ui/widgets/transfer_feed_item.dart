import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../features/transfers/models/transfer_item.dart';

class TransferFeedItem extends StatelessWidget {
  final TransferItem item;

  const TransferFeedItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIncoming = item.direction == TransferDirection.incoming;
    final timeStr = DateFormat('HH:mm').format(item.timestamp);

    IconData typeIcon;
    Color typeColor;
    String typeLabel;

    switch (item.type) {
      case TransferType.text:
        typeIcon = Icons.text_snippet_outlined;
        typeColor = const Color(0xFF38BDF8);
        typeLabel = 'Texto';
        break;
      case TransferType.photo:
        typeIcon = Icons.image_outlined;
        typeColor = const Color(0xFF34D399);
        typeLabel = 'Foto';
        break;
      case TransferType.file:
        typeIcon = Icons.insert_drive_file_outlined;
        typeColor = const Color(0xFFA78BFA);
        typeLabel = 'Arquivo';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeIcon, color: typeColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                typeLabel,
                style: TextStyle(
                  color: typeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isIncoming ? const Color(0xFF34D399) : const Color(0xFF38BDF8),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                isIncoming ? 'De: ${item.deviceName}' : 'Para: ${item.deviceName}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (item.type == TransferType.text)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.fileName.isNotEmpty ? item.fileName : item.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.formattedSize.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    item.formattedSize,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ],
            ),
          if (item.type == TransferType.text) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Texto copiado para o clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text('Copiar Novamente', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF38BDF8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
