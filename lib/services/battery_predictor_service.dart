class BatteryPredictorService {
  // Estimare bazată pe viteză medie și timp (fără date reale de baterie)
  double _averageSpeed = 0;
  int _tripDurationSeconds = 0;
  DateTime? _tripStartTime;
  
  // Parametri estimati (ajustabili după experiență)
  static const double BASE_RANGE_KM = 25.0; // Autonomie declarată
  static const double SPEED_PENALTY_FACTOR = 0.02; // Penalizare per km/h peste 15
  
  void startTrip() {
    _tripStartTime = DateTime.now();
    _averageSpeed = 0;
    _tripDurationSeconds = 0;
  }
  
  void updateSpeed(double currentSpeed) {
    if (_tripStartTime == null) return;
    
    _tripDurationSeconds++;
    
    // Media mobilă a vitezei
    _averageSpeed = (_averageSpeed * (_tripDurationSeconds - 1) + currentSpeed) 
                    / _tripDurationSeconds;
  }
  
  String getEstimatedRange() {
    if (_tripStartTime == null) return "Necunoscut";
    
    // Calcul penalizare viteză
    double speedPenalty = 0;
    if (_averageSpeed > 15) {
      speedPenalty = (_averageSpeed - 15) * SPEED_PENALTY_FACTOR * BASE_RANGE_KM;
    }
    
    double estimatedRange = BASE_RANGE_KM - speedPenalty;
    return "${estimatedRange.toStringAsFixed(1)} km";
  }
  
  String getTripDuration() {
    if (_tripStartTime == null) return "00:00";
    
    Duration duration = DateTime.now().difference(_tripStartTime!);
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
  
  void endTrip() {
    _tripStartTime = null;
  }
}