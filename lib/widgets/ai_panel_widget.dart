import 'package:flutter/material.dart';

class AIPanelWidget extends StatelessWidget {
  final Map<String, dynamic> tripStats;
  final String estimatedRange;
  final String tripDuration;
  final bool isVoiceListening;
  final VoidCallback onVoiceTap;
  
  const AIPanelWidget({
    super.key,
    required this.tripStats,
    required this.estimatedRange,
    required this.tripDuration,
    required this.isVoiceListening,
    required this.onVoiceTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🤖 AI Assistant',
            style: TextStyle(color: Colors.purple, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox('📍 Distanță', '${tripStats['total_distance_km']} km'),
              _buildStatBox('⚡ Viteză Max', '${tripStats['max_speed_kmh']} km/h'),
              _buildStatBox(' Autonomie', estimatedRange),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox('⏱️ Timp', tripDuration),
              _buildStatBox('📊 Viteză Medie', '${tripStats['average_speed_kmh']} km/h'),
              _buildStatBox('🏆 Scor', '${tripStats['eco_score']}/100'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onVoiceTap,
              icon: Icon(isVoiceListening ? Icons.mic : Icons.mic_none),
              label: Text(isVoiceListening ? 'Ascultă...' : 'Comandă Vocală'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isVoiceListening ? Colors.red : Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          if (tripStats['feedback'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                tripStats['feedback'],
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}