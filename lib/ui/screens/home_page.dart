import 'package:flutter/material.dart';
import '../../core/network/local_server.dart';
import '../../features/clipboard/services/clipboard_service.dart';
import '../../features/pairing/screens/qr_scanner_screen.dart';
import 'devices_tab.dart';
import 'transfers_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final ClipboardService _clipboard = ClipboardService();
  final GlobalKey<State> _devicesTabKey = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clipboard.checkAndSyncOnResume();
    }
  }

  void _openScanner() async {
    final serverPort = LocalServer().port;
    final paired = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(localListenAddr: '0.0.0.0:$serverPort'),
      ),
    );

    if (paired == true) {
      // Switch back to devices tab and reload
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sync_alt_rounded, color: Color(0xFF06B6D4), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'OmniDesk',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF38BDF8)),
            tooltip: 'Escanear QR Code',
            onPressed: _openScanner,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DevicesTab(
            key: _devicesTabKey,
            onOpenScanner: _openScanner,
          ),
          const TransfersTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF0F172A),
          selectedItemColor: const Color(0xFF06B6D4),
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.computer_rounded),
              label: 'Computadores',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sync_rounded),
              label: 'Transferências',
            ),
          ],
        ),
      ),
    );
  }
}
