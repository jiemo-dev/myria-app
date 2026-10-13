import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/ai_coach_service.dart';
import '../services/voice_assistant_service.dart';
import '../services/battery_predictor_service.dart';
import '../services/route_analyzer_service.dart';
import '../widgets/speed_widget.dart';
import '../widgets/ai_panel_widget.dart';

class CockpitScreen extends StatefulWidget {
  const CockpitScreen({super.key});

  @override
  State<CockpitScreen> createState() => _CockpitScreenState();
}

class _CockpitScreenState extends State<CockpitScreen> {
  // BLE
  BluetoothDevice? _device;
  bool _isConnected = false;
  String _btStatus = "NECONECTAT";

  // GPS & Map
  final MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(44.4268, 26.1025);
  List<LatLng> _routePoints = [];

  // AI Services
  final AICoachService _aiCoach = AICoachService();
  final VoiceAssistantService _voiceAssistant = VoiceAssistantService();
  final BatteryPredictorService _batteryPredictor = BatteryPredictorService();
  final RouteAnalyzerService _routeAnalyzer = RouteAnalyzerService();

  double _currentSpeedKmh = 0.0;
  String _gpsStatus = "Aștept GPS...";
  bool _isVoiceListening = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _aiCoach.init();
    _initVoiceAssistant();
    _initLocation();
    _batteryPredictor.startTrip();
  }

  Future<void> _initVoiceAssistant() async {
    await _voiceAssistant.init();
    _voiceAssistant.onCommandRecognized = _handleVoiceCommand;
  }

  void _handleVoiceCommand(String command) {
    setState(() {
      switch (command) {
        case 'battery_status':
          _showSnackBar('🔋 Autonomie estimată: ${_batteryPredictor.getEstimatedRange()}');
          break;
        case 'speed_status':
          _showSnackBar('⚡ Viteză curentă: ${_currentSpeedKmh.toStringAsFixed(1)} km/h');
          break;
        case 'start_route':
          _routeAnalyzer.reset();
          _aiCoach.resetTrip();
          _batteryPredictor.startTrip();
          _showSnackBar('🗺️ Traseu nou început!');
          break;
        case 'stop_route':
          _batteryPredictor.endTrip();
          _showSnackBar('🏁 Traseu oprit!');
          break;
        case 'eco_score':
          var stats = _aiCoach.getTripStats();
          _showSnackBar('🏆 Scor Eco: ${stats['eco_score']}/100');
          break;
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      setState(() { _gpsStatus = "GPS Activ..."; });
      
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((Position position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _currentSpeedKmh = position.speed * 3.6;
          if (_currentSpeedKmh < 0) _currentSpeedKmh = 0;
          _gpsStatus = "GPS Blocat (${position.accuracy.toStringAsFixed(0)}m)";
          
          _routePoints.add(_currentPosition);
          _aiCoach.updateSpeed(_currentSpeedKmh);
          _batteryPredictor.updateSpeed(_currentSpeedKmh);
          _routeAnalyzer.addPoint(_currentPosition, _currentSpeedKmh);
        });
      });
    } else {
      setState(() { _gpsStatus = "Permisiune GPS refuzată!"; });
    }
  }

  Future<void> _connectToScooter() async {
    if (_isConnected) {
      await _device?.disconnect();
      setState(() { _isConnected = false; _btStatus = "NECONECTAT"; });
      return;
    }

    setState(() { _btStatus = "CĂUTARE..."; });
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult result in results) {
          if (result.device.platformName.contains('M0Robot')) {
            await FlutterBluePlus.stopScan();
            await result.device.connect();
            setState(() { 
              _device = result.device;
              _isConnected = true; 
              _btStatus = "CONECTAT BT"; 
            });
            break;
          }
        }
      });
    } catch (e) { 
      setState(() { _btStatus = "EROARE BT"; });
    }
  }

  void _toggleVoiceAssistant() {
    setState(() {
      if (_isVoiceListening) {
        _voiceAssistant.stopListening();
        _isVoiceListening = false;
      } else {
        _voiceAssistant.startListening();
        _isVoiceListening = true;
        _showSnackBar('🎤 Spune o comandă: "baterie", "viteză", "traseu", "scor"');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var tripStats = _routeAnalyzer.getRouteStats();
    tripStats.addAll(_aiCoach.getTripStats());

    return Scaffold(
      body: Stack(
        children: [
          // Harta
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.myria_app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 6.0,
                    color: Colors.blueAccent.withOpacity(0.8),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.navigation, color: Colors.red, size: 35),
                  ),
                ],
              ),
            ],
          ),

          // Viteză + Eco Score (sus stânga)
          Positioned(
            top: 40,
            left: 16,
            child: SpeedWidget(
              speed: _currentSpeedKmh,
              ecoScore: _aiCoach.calculateEcoScore(),
            ),
          ),

          // Status BT + GPS (sus dreapta)
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_btStatus, style: TextStyle(color: _isConnected ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_gpsStatus, style: const TextStyle(color: Colors.blue, fontSize: 10)),
                ],
              ),
            ),
          ),

          // Buton Conectare BT
          Positioned(
            top: 180,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _connectToScooter,
              icon: Icon(_isConnected ? Icons.bluetooth_disabled : Icons.bluetooth_searching),
              label: Text(_isConnected ? 'DECONECTEAZĂ' : 'CONECTEAZĂ M0ROBOT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnected ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // AI Panel (jos)
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: AIPanelWidget(
              tripStats: tripStats,
              estimatedRange: _batteryPredictor.getEstimatedRange(),
              tripDuration: _batteryPredictor.getTripDuration(),
              isVoiceListening: _isVoiceListening,
              onVoiceTap: _toggleVoiceAssistant,
            ),
          ),

          // Buton Centrare Hartă
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                _mapController.move(_currentPosition, 17.0);
              },
              backgroundColor: Colors.black87,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _voiceAssistant.stopListening();
    _batteryPredictor.endTrip();
    super.dispose();
  }
}