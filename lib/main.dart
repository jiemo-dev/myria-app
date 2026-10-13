import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myria Minimal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Fundal negru, economisește baterie și arată bine
      home: const ScooterScreen(),
    );
  }
}

class ScooterScreen extends StatefulWidget {
  const ScooterScreen({super.key});

  @override
  State<ScooterScreen> createState() => _ScooterScreenState();
}

class _ScooterScreenState extends State<ScooterScreen> {
  bool _isConnected = false;
  String _status = "NECONECTAT";
  BluetoothDevice? _device;

  Future<void> _toggleConnection() async {
    if (_isConnected) {
      await _device?.disconnect();
      setState(() {
        _isConnected = false;
        _status = "NECONECTAT";
        _device = null;
      });
      return;
    }

    setState(() => _status = "SCANEZ...");
    
    // Scanează timp de 4 secunde
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        if (result.device.platformName.contains('M0Robot')) {
          await FlutterBluePlus.stopScan();
          setState(() => _status = "SE CONECTEAZĂ...");
          
          try {
            await result.device.connect();
            setState(() {
              _device = result.device;
              _isConnected = true;
              _status = "✅ CONECTAT LA M0ROBOT!";
            });
          } catch (e) {
            setState(() => _status = "EROARE CONECTARE: $e");
          }
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Myria Minimal Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isConnected ? Colors.green : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggleConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnected ? Colors.red : Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: Text(
                _isConnected ? 'DECONECTEAZĂ' : 'CONECTEAZĂ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}