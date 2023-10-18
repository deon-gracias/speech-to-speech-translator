import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const List<List<String>> list = [
  ["Hindi", "hi"],
  ["Punjabi", "pa"],
  ["Sanskrit", "sa"],
  ["Bengali", "bn"],
  ["Marathi", "mr"],
  ["Gujarati", "gu"],
  ["Urdu", "ur"],
  ["Assamese", "as"],
  ["Odia", "or"],
  ["Nepali", "ne"],
  ["Maithili", "mai"],
  ["Konkani", "gom"],
  ["Santali", "sat"],
  ["Sindhi", "sd"],
  ["Dogri", "doi"],
  ["Meiteilon", "mni-Mtei"],
  ["Bhojpuri", "bho"]
];

class _MyHomePageState extends State<MyHomePage> {
  final translator = GoogleTranslator();
  final SpeechToText _speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _translated = '';
  String targetLanguage = list.first[1];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    flutterTts.setLanguage(targetLanguage);
    flutterTts.setSpeechRate(0.40);
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      translate();
    });
  }

  _speak(String text) async {
    if (_speechToText.isListening) return;
    var result = await flutterTts.speak(text);
    if (result == 1) {
      //speaking
    } else {
      //not speaking
    }
  }

  Future<void> translate() async {
    if (_speechToText.isListening) return;

    final output = await translator.translate(_lastWords, to: targetLanguage);
    setState(() {
      _translated = output.text;
    });
    _speak(output.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Demo'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownMenu<String>(
                initialSelection: targetLanguage,
                onSelected: (String? value) {
                  setState(() {
                    targetLanguage = value!;
                  });
                },
                dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((e) {
                  return DropdownMenuEntry<String>(
                    value: e[1],
                    label: e[0],
                  );
                }).toList(),
              ),
              Text('$_translated'),
              Text('$_lastWords'),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    _speechToText.isListening
                        ? '$_lastWords'
                        : _speechEnabled
                            ? 'Tap the microphone to start listening...'
                            : 'Speech not available',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            // If not yet listening for speech start, otherwise stop
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
