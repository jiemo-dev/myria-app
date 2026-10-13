import 'package:flutter/material.dart';

class SpeedWidget extends StatelessWidget {
  final double speed;
  final int ecoScore;
  
  const SpeedWidget({
    super.key,
    required this.speed,
    required this.ecoScore,
  });
  
  Color _getSpeedColor() {
    if (speed < 10) return Colors.green;
    if (speed < 20) return Colors.orange;
    return Colors.red;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getSpeedColor(), width: 2),
      ),
      child: Column(
        children: [
          Text(
            speed.toStringAsFixed(1),
            style: TextStyle(
              color: _getSpeedColor(),
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text('KM/H', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Eco: $ecoScore',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}