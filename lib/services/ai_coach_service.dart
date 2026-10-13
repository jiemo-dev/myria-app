import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class DrivingEvent {
  final DateTime timestamp;
  final String type; // 'harsh_accel', 'harsh_brake', 'smooth'
  final double intensity;
  
  DrivingEvent({required this.timestamp, required this.type, required this.intensity});
}

class AICoachService {
  final List<DrivingEvent> _events = [];
  double _lastSpeed = 0;
  DateTime _lastUpdate = DateTime.now();
  
  // Stream pentru accelerometru
  Stream<UserAccelerometerEvent>? _accelStream;
  
  void init() {
    _accelStream = userAccelerometerEventStream();
    _accelStream!.listen((event) {
      _analyzeAcceleration(event);
    });
  }
  
  void _analyzeAcceleration(UserAccelerometerEvent event) {
    DateTime now = DateTime.now();
    double timeDiff = now.difference(_lastUpdate).inMilliseconds / 1000;
    
    if (timeDiff < 0.1) return; // Evităm zgomot
    
    double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );
    
    // Praguri pentru evenimente (ajustabile)
    if (acceleration > 15) {
      _events.add(DrivingEvent(
        timestamp: now,
        type: 'harsh_accel',
        intensity: acceleration
      ));
    } else if (acceleration < -10) {
      _events.add(DrivingEvent(
        timestamp: now,
        type: 'harsh_brake',
        intensity: acceleration.abs()
      ));
    }
    
    _lastUpdate = now;
  }
  
  void updateSpeed(double speed) {
    _lastSpeed = speed;
  }
  
  // Calculează scorul de conducere (0-100)
  int calculateEcoScore() {
    if (_events.isEmpty) return 100;
    
    int harshAccels = _events.where((e) => e.type == 'harsh_accel').length;
    int harshBrakes = _events.where((e) => e.type == 'harsh_brake').length;
    
    // Penalizări
    int penalty = (harshAccels * 5) + (harshBrakes * 3);
    int score = 100 - penalty;
    
    return score.clamp(0, 100);
  }
  
  String getFeedback() {
    int score = calculateEcoScore();
    
    if (score >= 90) return " Conducere excelentă!";
    if (score >= 75) return " Bine, dar poți mai bine";
    if (score >= 60) return "⚠️ Ai avut câteva accelerații bruște";
    return "🚨 Conducere agresivă! Economisește bateria";
  }
  
  void resetTrip() {
    _events.clear();
  }
  
  Map<String, dynamic> getTripStats() {
    return {
      'eco_score': calculateEcoScore(),
      'feedback': getFeedback(),
      'harsh_accels': _events.where((e) => e.type == 'harsh_accel').length,
      'harsh_brakes': _events.where((e) => e.type == 'harsh_brake').length,
      'total_events': _events.length,
    };
  }
}