import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CoffeeAssistant(),
    );
  }
}

class CoffeeAssistant extends StatefulWidget {
  const CoffeeAssistant({super.key});

  @override
  State<CoffeeAssistant> createState() => _CoffeeAssistantState();
}

class _CoffeeAssistantState extends State<CoffeeAssistant> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _text = "";
  bool _isAdmin = false;

  final Map<String, String> _qaDatabase = {
    "ما هي أنواع القهوة": "هناك العديد من الأنواع مثل الإسبريسو، الكابتشينو، واللاتيه.",
    "كيف يتم تحميص البن": "تحميص البن يتم عند درجات حرارة مختلفة للحصول على نكهات مميزة.",
    "ما هي أفضل قهوة": "أفضل قهوة تعتمد على ذوقك، لكن قهوة الأرابيكا مشهورة بطعمها الناعم.",
    "كيف أحضر القهوة": "يمكنك تحضير القهوة باستخدام الفرنش برس، الإسبريسو ماشين أو القهوة التركية.",
  };

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  void _initializeTTS() async {
    await _tts.setLanguage("ar");
    await _tts.setSpeechRate(0.5);
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {},
      onError: (error) => print("Speech error: $error"),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() => _text = result.recognizedWords);
        _processQuestion(_text);
      });
    }
  }

  void _processQuestion(String question) {
    String answer = _getCoffeeAnswer(question);

    if (_isAdmin) {
      _tts.speak("يمكنك الآن تعديل البيانات");
    } else if (answer.isNotEmpty) {
      _tts.speak(answer);
    } else {
      _tts.speak("أنا متخصص فقط في القهوة ولا يمكنني الإجابة عن هذا السؤال");
    }
  }

  String _getCoffeeAnswer(String question) {
    question = question.toLowerCase();
    for (var entry in _qaDatabase.entries) {
      if (question.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return _isCoffeeRelated(question) ? "سأجيب عن سؤالك: $question" : "";
  }

  bool _isCoffeeRelated(String text) {
    List<String> keywords = ["قهوة", "بن", "إسبريسو", "كابتشينو", "تحميص", "كافيين"];
    return keywords.any((word) => text.contains(word));
  }

  void _adminLogin() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController passController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل دخول المشرف"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "الاسم"),
            ),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: "كلمة المرور"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text == "أنس الصباغ" && passController.text == "Anas@1979") {
                setState(() => _isAdmin = true);
                Navigator.pop(context);
                _tts.speak("تم تسجيل الدخول كمشرف");
              } else {
                _tts.speak("اسم المستخدم أو كلمة المرور غير صحيحة");
              }
            },
            child: const Text("تسجيل الدخول"),
          ),
        ],
      ),
    );
  }

  void _showAdminEditor() {
    TextEditingController questionController = TextEditingController();
    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة/تعديل سؤال"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: "السؤال"),
            ),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: "الإجابة"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              String q = questionController.text.trim();
              String a = answerController.text.trim();
              if (q.isNotEmpty && a.isNotEmpty) {
                setState(() => _qaDatabase[q] = a);
                Navigator.pop(context);
                _tts.speak("تم حفظ السؤال والإجابة");
              } else {
                _tts.speak("الرجاء إدخال السؤال والإجابة");
              }
            },
            child: const Text("حفظ"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("وكيل القهوة الذكي")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_isAdmin ? "وضع المشرف مفعل" : "وضع المستخدم العادي"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startListening,
              child: Text(_isListening ? "يستمع..." : "ابدأ التحدث"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _adminLogin,
              child: const Text("تسجيل دخول المشرف"),
            ),
            if (_isAdmin)
              ElevatedButton(
                onPressed: _showAdminEditor,
                child: const Text("إضافة أو تعديل سؤال"),
              ),
          ],
        ),
      ),
    );
  }
}
