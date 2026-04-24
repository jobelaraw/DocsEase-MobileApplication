import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> speak(String text, {VoidCallback? onDone}) async {
    await stop();
    await _tts.setLanguage('fil-PH').catchError((_) => _tts.setLanguage('en-US'));
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.2);
    await _tts.setVolume(1.0);

    final voices = await _tts.getVoices as List?;
    if (voices != null) {
      final femaleVoice = voices.cast<Map>().where((v) {
        final name = (v['name'] as String? ?? '').toLowerCase();
        final locale = (v['locale'] as String? ?? '').toLowerCase();
        final isFemale = name.contains('female') || name.contains('wavenet-f') ||
            name.contains('neural2-f') || name.contains('en-us-x-tpf') ||
            name.contains('en-us-x-tpc') || name.contains('zira') ||
            name.contains('samantha') || name.contains('karen');
        final isGoodLocale = locale.contains('fil') || locale.contains('en-us');
        return isFemale && isGoodLocale;
      }).toList();

      if (femaleVoice.isNotEmpty) {
        await _tts.setVoice({
          'name': femaleVoice.first['name'],
          'locale': femaleVoice.first['locale'],
        });
      }
    }

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      onDone?.call();
    });
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
