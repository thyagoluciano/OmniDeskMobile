import 'package:flutter/material.dart';
import '../../core/models/device.dart';
import '../../core/network/api_client.dart';
import '../../core/network/local_server.dart';
import '../../core/storage/storage_service.dart';
import '../../features/clipboard/services/clipboard_service.dart';
import '../../features/transfers/services/file_transfer_service.dart';
import '../widgets/computer_card.dart';

class DevicesTab extends StatefulWidget {
  final VoidCallback onOpenScanner;

  const DevicesTab({
    Key? key,
    required this.onOpenScanner,
  }) : super(key: key);

  @override
  State<DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  final StorageService _storage = StorageService();
  final ApiClient _api = ApiClient();
  final ClipboardService _clipboard = ClipboardService();
  final FileTransferService _fileTransfer = FileTransferService();

  List<TrustedDevice> _devices = [];
  bool _isLoading = true;
  String _myDeviceName = '';
  String _myDeviceId = '';

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    final myName = await _storage.getDeviceName();
    final myId = await _storage.getDeviceId();
    final list = await _storage.getTrustedDevices();

    // Check connectivity for each device
    final updated = await Future.wait(
      list.map((d) async {
        final online = await _api.checkStatus(d.lastAddr);
        return d.copyWith(isOnline: online);
      }),
    );

    if (!mounted) return;
    setState(() {
      _myDeviceName = myName;
      _myDeviceId = myId;
      _devices = updated;
      _isLoading = false;
    });
  }

  void _sendClipboard(TrustedDevice dev) async {
    final ok = await _clipboard.sendCurrentClipboardToDevice(dev);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Clipboard enviado para ${dev.name}!' : 'Área de transferência vazia ou falha no envio.'),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendPhoto(TrustedDevice dev) async {
    final count = await _fileTransfer.pickAndSendPhotos(dev);
    if (!mounted) return;
    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count foto(s) enviada(s) com sucesso para ${dev.name}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _sendFile(TrustedDevice dev) async {
    final count = await _fileTransfer.pickAndSendFiles(dev);
    if (!mounted) return;
    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count arquivo(s) enviado(s) com sucesso para ${dev.name}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeDevice(TrustedDevice dev) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Desconectar ${dev.name}?'),
        content: const Text('Para sincronizar novamente será necessário escanear o QR Code deste computador.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.removeTrustedDevice(dev.id);
      _loadDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDevices,
      color: const Color(0xFF06B6D4),
      backgroundColor: const Color(0xFF1E293B),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          // Local Node Status Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E7490), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smartphone_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _myDeviceName.isNotEmpty ? _myDeviceName : 'Meu Smartphone',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Porta: ${LocalServer().port} • $_myDeviceId',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'COMPUTADORES PAREADOS',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_devices.length} conectado(s)',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
              ),
            )
          else if (_devices.isEmpty)
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155), strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: Column(
                children: [
                  Icon(Icons.devices_other_rounded, size: 54, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum computador pareado',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Abra o painel web no seu computador e toque no botão abaixo para escanear o QR Code.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: widget.onOpenScanner,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Escanear QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._devices.map(
              (dev) => ComputerCard(
                device: dev,
                onSendClipboard: () => _sendClipboard(dev),
                onSendPhoto: () => _sendPhoto(dev),
                onSendFile: () => _sendFile(dev),
                onRemove: () => _removeDevice(dev),
              ),
            ),
        ],
      ),
    );
  }
}
