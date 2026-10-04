import 'package:flutter/material.dart';
import 'core/network/local_server.dart';
import 'ui/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start local server to receive incoming clips/files on LAN
  await LocalServer().start();

  runApp(const OmniDeskApp());
}

class OmniDeskApp extends StatelessWidget {
  const OmniDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniDesk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF06B6D4), // Cyan
          secondary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
          background: Color(0xFF0F172A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}
