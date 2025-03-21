import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIMessageAssistantPage extends StatefulWidget {
  const AIMessageAssistantPage({super.key});

  @override
  _AIMessageAssistantPageState createState() => _AIMessageAssistantPageState();
}

class _AIMessageAssistantPageState extends State<AIMessageAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> chatMessages = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _messageController.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _sendMessage() {
    String userMessage = _messageController.text.trim();
    if (userMessage.isNotEmpty) {
      setState(() {
        chatMessages.add({"sender": "User", "message": userMessage});
        _messageController.clear();
      });
      _generateAIResponse(userMessage);
    }
  }

  void _generateAIResponse(String userMessage) {
    // Simulated AI response (Replace with actual AI integration)
    String aiResponse = "Here's a heartfelt message idea for you: 'Keep believing in yourself. The future is bright!'";
    
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        chatMessages.add({"sender": "AI", "message": aiResponse});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Message Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                var msg = chatMessages[index];
                return Align(
                  alignment: msg["sender"] == "User" ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg["sender"] == "User" ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg["message"]!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.red),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: "Type your message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
