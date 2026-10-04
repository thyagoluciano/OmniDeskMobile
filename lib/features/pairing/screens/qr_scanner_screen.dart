import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/qr_payload.dart';
import '../services/pairing_service.dart';

class QRScannerScreen extends StatefulWidget {
  final String localListenAddr;

  const QRScannerScreen({
    Key? key,
    this.localListenAddr = '',
  }) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
    autoZoom: true,
  );

  bool _isProcessing = false;
  String? _statusText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;

      final payload = QRPairPayload.tryParse(raw);
      if (payload == null) {
        if (mounted) {
          setState(() => _statusText = 'QR lido, mas não é do OmniDesk');
        }
        continue;
      }

      setState(() {
        _isProcessing = true;
        _statusText = 'Conectando a ${payload.name}...';
      });

      try {
        final device = await PairingService().pairWithQRPayload(
          payload,
          localListenAddr: widget.localListenAddr,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} pareado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true);
        return;
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isProcessing = false;
          _statusText = null;
        });

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Falha no Pareamento'),
            content: Text('Não foi possível conectar ao computador: ${e.toString().replaceAll('Exception: ', '')}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Lanterna',
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            tooltip: 'Alternar Câmera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Custom scanner overlay
          CustomPaint(
            painter: _ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),
          // Status indicator or instructions
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.cyanAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _statusText ?? 'Processando...',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      )
                    : Text(
                        _statusText ?? 'Aponte para o QR Code no seu computador',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanSize = size.width * 0.72;
    final double left = (size.width - scanSize) / 2;
    final double top = (size.height - scanSize) / 2.2;
    final rect = Rect.fromLTWH(left, top, scanSize, scanSize);

    // Dark semi-transparent backdrop
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.55);
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(bgPath, bgPaint);

    // Corner lines
    final cornerPaint = Paint()
      ..color = const Color(0xFF06B6D4) // Cyan / Teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 26.0;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(left + scanSize - cornerLength, top), Offset(left + scanSize, top), cornerPaint);
    canvas.drawLine(Offset(left + scanSize, top), Offset(left + scanSize, top + cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, top + scanSize - cornerLength), Offset(left, top + scanSize), cornerPaint);
    canvas.drawLine(Offset(left, top + scanSize), Offset(left + cornerLength, top + scanSize), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(left + scanSize - cornerLength, top + scanSize), Offset(left + scanSize, top + scanSize), cornerPaint);
    canvas.drawLine(Offset(left + scanSize, top + scanSize - cornerLength), Offset(left + scanSize, top + scanSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
