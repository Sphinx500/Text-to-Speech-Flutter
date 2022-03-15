import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String defaultLanguage = 'ES';

  TextToSpeech tts = TextToSpeech();

  String text = '';

  // double volume = 1; // Range: 0-1
  // double rate = 1.0; // Range: 0-2
  // double pitch = 1.0; // Range: 0-2

  String? language;
  String? languageCode;
  List<String> languages = <String>[];
  List<String> languageCodes = <String>[];

  String? voice;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = text;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initLanguages();
    });
  }

  Future<void> initLanguages() async {
    /// populate lang code (i.e. en-US)
    languageCodes = await tts.getLanguages();

    /// populate displayed language (i.e. English)
    final List<String>? displayLanguages = await tts.getDisplayLanguages();
    if (displayLanguages == null) {
      return;
    }

    languages.clear();
    for (final dynamic lang in displayLanguages) {
      languages.add(lang as String);
    }

    final String? defaultLangCode = await tts.getDefaultLanguage();
    if (defaultLangCode != null && languageCodes.contains(defaultLangCode)) {
      languageCode = defaultLangCode;
    } else {
      languageCode = defaultLanguage;
    }
    language = await tts.getDisplayLanguageByCode(languageCode!);

    /// get voice
    voice = await getVoiceByLang(languageCode!);

    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getVoiceByLang(String lang) async {
    final List<String>? voices = await tts.getVoiceByLang(languageCode!);
    if (voices != null && voices.isNotEmpty) {
      return voices.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Texto a Voz'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: textEditingController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Texto'),

                    //TODO Aqui recibe el texto como parametro de entrada
                    onChanged: (String newText) {
                      setState(() {
                        text = newText;
                      });
                    },
                  ),
                  Row(
                    children: <Widget>[
                      const Text('Language'),
                      const SizedBox(
                        width: 20,
                      ),
                      DropdownButton<String>(
                        value: language,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        
                        //TODO Metodo para cambiar el idioma
                        onChanged: (String? newValue) async {
                          languageCode =
                              await tts.getLanguageCodeByName(newValue!);
                          voice = await getVoiceByLang(languageCode!);
                          setState(() {
                            language = newValue;
                          });
                        },
                        items: languages
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      const Text('Voice'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(voice ?? '-'),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            child: const Text('Stop'),
                            onPressed: () {
                              tts.stop();
                            },
                          ),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        child: ElevatedButton(
                          child: const Text('Speak'),
                          //TODO Funcion para hablar
                          onPressed: () {
                            speak();
                          },
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get supportPause => defaultTargetPlatform != TargetPlatform.android;

  bool get supportResume => defaultTargetPlatform != TargetPlatform.android;


//TODO AQUI SE DEFINE LA FUNCION
  void speak() {
    // if (languageCode != null) {
    //   tts.setLanguage(languageCode!);
    // }
    tts.speak(text);
  }
}