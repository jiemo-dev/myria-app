import 'package:speech_to_text/speech_to_text.dart';

class VoiceAssistantService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  String _lastWords = '';
  Function(String)? onCommandRecognized;
  
  Future<void> init() async {
    _isInitialized = await _speech.initialize(
      onError: (error) => print('Eroare voice: $error'),
      onStatus: (status) => print('Status voice: $status'),
    );
  }
  
  void startListening() {
    if (!_isInitialized) return;
    
    _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        _processCommand(_lastWords);
      },
      localeId: 'ro_RO', // Română
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }
  
  void stopListening() {
    _speech.stop();
  }
  
  void _processCommand(String command) {
    String lowerCmd = command.toLowerCase();
    
    // Comenzi recunoscute
    if (lowerCmd.contains('baterie') || lowerCmd.contains('battery')) {
      onCommandRecognized?.call('battery_status');
    } else if (lowerCmd.contains('viteză') || lowerCmd.contains('speed')) {
      onCommandRecognized?.call('speed_status');
    } else if (lowerCmd.contains('traseu') || lowerCmd.contains('route')) {
      onCommandRecognized?.call('start_route');
    } else if (lowerCmd.contains('stop') || lowerCmd.contains('oprește')) {
      onCommandRecognized?.call('stop_route');
    } else if (lowerCmd.contains('scor') || lowerCmd.contains('score')) {
      onCommandRecognized?.call('eco_score');
    }
  }
  
  bool get isListening => _speech.isListening;
  String get lastWords => _lastWords;
}