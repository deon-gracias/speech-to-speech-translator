import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
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
  ["Sanskrit", "sa"],
  ["Bengali", "bn"],
  ["Marathi", "mr"],
  ["Nepali", "ne"],
  ["Gujarati", "gu"], // No TTS
  ["Punjabi", "pa"], // No TTS
  ["Urdu", "ur"], // No TTS
  ["Sindhi", "sd"], // No TTS
  // ["Assamese", "as"], // No Translation
  // ["Odia", "or"], // No Translation
  // ["Maithili", "mai"], // No Translation
  // ["Konkani", "gom"], // No Translation
  // ["Santali", "sat"], // No Translation
  // ["Dogri", "doi"], // No Translation
  // ["Meiteilon", "mni-Mtei"], No Translation
  // ["Bhojpuri", "bho"] // No Translation
];

class _MyHomePageState extends State<MyHomePage> {
  final translator = GoogleTranslator();
  final azureTts = AzureTts.init(
      subscriptionKey: "6f062081b3b1440f91afbffbf24e77d1",
      region: "eastus",
      withLogs: true);

  final SpeechToText _speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  TextEditingController outputController = TextEditingController();
  TextEditingController inputController = TextEditingController();
  bool _speechEnabled = false;
  // String _lastWords = '';
  // String _translated = '';
  String targetLanguage = list.first[1];

  // Get available voices

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
      inputController.text = result.recognizedWords;
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

    final output =
        await translator.translate(inputController.text, to: targetLanguage);
    setState(() {
      outputController.text = output.text;
    });
    _speak(output.text);
  }

  // azureTranslate() async {
  //   final voicesResponse = await AzureTts.getAvailableVoices();

  //   //List all available voices
  //   print("${voicesResponse.voices}");

  //   //Pick a Neural voice
  //   final voice = voicesResponse.voices
  //       .where((element) => element.locale.startsWith(targetLanguage))
  //       .toList(growable: false)
  //       .first;

  //   TtsParams params = TtsParams(
  //       voice: voice,
  //       audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
  //       rate: 1.5, // optional prosody rate (default is 1.0)
  //       text: outputController.text);

  //   final ttsResponse = await AzureTts.getTts(params);

  //   //Get the audio bytes.
  //   final audioBytes = ttsResponse.audio.buffer.asByteData();
  //   ttsResponse.audio.buffer.

  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Demo'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // DropdownMenu<String>(
              //   label: const Text("From"),
              //   initialSelection: targetLanguage,
              //   width: 200,
              //   menuHeight: 300,
              //   onSelected: (String? value) {
              //     setState(() {
              //       targetLanguage = value!;
              //     });
              //   },
              //   dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((e) {
              //     return DropdownMenuEntry<String>(
              //       value: e[1],
              //       label: e[0],
              //     );
              //   }).toList(),
              // ),
              // const SizedBox(height: 5),
              TextField(
                controller: inputController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "Input Text"),
                maxLines: 8,
              ),
              ElevatedButton(
                onPressed: () => translate(),
                child: const Text("Translate"),
              ),
              const SizedBox(height: 40),
              DropdownMenu<String>(
                label: const Text("To"),
                initialSelection: targetLanguage,
                width: 200,
                menuHeight: 300,
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
              const SizedBox(height: 5),
              TextField(
                controller: outputController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "Output Text"),
                maxLines: 8,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
