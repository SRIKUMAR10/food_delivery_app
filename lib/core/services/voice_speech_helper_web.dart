import 'dart:html' as html;

/// Web Speech Synthesis implementation for Chrome, Edge, Safari, and Firefox browsers
void speakWebText(String text, {String lang = 'en-US', double rate = 1.0}) {
  try {
    final synth = html.window.speechSynthesis;
    if (synth != null) {
      synth.cancel(); // Cancel any lingering speech to avoid queue congestion
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = lang;
      utterance.rate = rate;
      utterance.pitch = 1.0;
      utterance.volume = 1.0;
      synth.speak(utterance);
    }
  } catch (_) {}
}
