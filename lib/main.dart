import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'messages_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, isUser INTEGER)',
      );
    },
    version: 1,
  );

  runApp(RitmoApp(database: database));
}

class RitmoApp extends StatelessWidget {
  final Future<Database> database;
  const RitmoApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RitmoApp – Produtividade Remota',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        scaffoldBackgroundColor: const Color(0xFFF4F9FF),
      ),
      debugShowCheckedModeBanner: false,
      home: ProductivityScreen(database: database),
    );
  }
}

class Message {
  final String text;
  final bool isUser;

  Message(this.text, this.isUser);

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser ? 1 : 0,
    };
  }
}

class ProductivityScreen extends StatefulWidget {
  final Future<Database> database;
  const ProductivityScreen({Key? key, required this.database}) : super(key: key);

  @override
  State<ProductivityScreen> createState() => _ProductivityScreenState();
}

class _ProductivityScreenState extends State<ProductivityScreen> {
  final TextEditingController _taskController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadMessages();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => setState(() => _isListening = false),
    );
  }

  Future<void> _loadMessages() async {
    final Database db = await widget.database;
    final List<Map<String, dynamic>> maps = await db.query('messages');

    setState(() {
      _messages.clear();
      _messages.addAll(maps.map((m) => Message(m['text'], m['isUser'] == 1)));
    });
  }

  Future<void> _saveMessage(Message message) async {
    final Database db = await widget.database;
    await db.insert('messages', message.toMap());
  }

  Future<void> _clearMessages() async {
    final Database db = await widget.database;
    await db.delete('messages');
    setState(() => _messages.clear());
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _taskController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _getProductivityTip() async {
    final userInput = _taskController.text.trim();
    if (userInput.isEmpty) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Descreva sua rotina ou desafio atual.')),
      );
      return;
    }

    final userMessage = Message(userInput, true);
    setState(() {
      _isLoading = true;
      _messages.add(userMessage);
    });
    _saveMessage(userMessage);

    try {
      final String apiKey = 'AIzaSyDBZh849Mw0YiKZXfLxQNwI_Um0Y7GOsRw';
      final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

      final String prompt = '''
        Você é um assistente de produtividade para trabalho remoto.
        Baseado no seguinte desafio ou rotina: "$userInput"
        Sugira práticas de foco, organização, pausas saudáveis e equilíbrio.
        Mantenha o tom objetivo, encorajador e direto ao ponto. Mas utilize também emojis apropriados para dar um toque mais humano e divertido.
      ''';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.6,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 600,
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final String content = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        final botMessage = Message(content, false);
        setState(() => _messages.add(botMessage));
        _saveMessage(botMessage);
      } else {
        setState(() => _messages.add(Message('Erro ao obter resposta: \${response.statusCode}', false)));
      }
    } catch (e) {
      setState(() => _messages.add(Message('Erro ao conectar com a API: \$e', false)));
    } finally {
      setState(() => _isLoading = false);
    }

    _taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo_branca.png',
          height: 160,
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearMessages();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Limpar chat'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser ? Colors.blueAccent : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Descreva uma tarefa ou desafio...',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                IconButton(
                  onPressed: _listen,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.blueAccent,
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _getProductivityTip,
                  icon: _isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send, color: Colors.blueAccent),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}