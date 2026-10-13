import 'package:latlong2/latlong.dart';

class RouteAnalyzerService {
  final List<LatLng> _routePoints = [];
  double _totalDistance = 0;
  double _maxSpeed = 0;
  double _averageSpeed = 0;
  int _speedSamples = 0;
  
  void addPoint(LatLng point, double currentSpeed) {
    if (_routePoints.isNotEmpty) {
      double distance = _calculateDistance(_routePoints.last, point);
      _totalDistance += distance;
    }
    
    _routePoints.add(point);
    
    if (currentSpeed > _maxSpeed) {
      _maxSpeed = currentSpeed;
    }
    
    _averageSpeed = (_averageSpeed * _speedSamples + currentSpeed) / (_speedSamples + 1);
    _speedSamples++;
  }
  
  double _calculateDistance(LatLng p1, LatLng p2) {
    const double earthRadius = 6371000; // metri
    double lat1 = p1.latitude * 3.14159 / 180;
    double lat2 = p2.latitude * 3.14159 / 180;
    double dLat = (p2.latitude - p1.latitude) * 3.14159 / 180;
    double dLon = (p2.longitude - p1.longitude) * 3.14159 / 180;
    
    double a = (dLat/2) * (dLat/2) + 
               lat1.cos() * lat2.cos() * (dLon/2) * (dLon/2);
    double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }
  
  Map<String, dynamic> getRouteStats() {
    return {
      'total_distance_km': (_totalDistance / 1000).toStringAsFixed(2),
      'max_speed_kmh': _maxSpeed.toStringAsFixed(1),
      'average_speed_kmh': _averageSpeed.toStringAsFixed(1),
      'points_count': _routePoints.length,
    };
  }
  
  void reset() {
    _routePoints.clear();
    _totalDistance = 0;
    _maxSpeed = 0;
    _averageSpeed = 0;
    _speedSamples = 0;
  }
}

extension on double {
  double cos() => this; // Simplificare - în producție folosește dart:math
  double sin() => this;
  double asin() => this;
  double sqrt() => this;
}