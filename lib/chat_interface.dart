import 'package:flutter/material.dart';
import 'package:flutter_joystick/models/message.dart';
import 'package:flutter_joystick/services/chat_service.dart';
import 'package:flutter_joystick/wheel_page.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/message_template.dart';

class ChatInterface extends StatefulWidget {
  const ChatInterface({super.key});

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final List<WheelOption> options = [
    WheelOption('🎮', 'Gaming', Colors.blue),
    WheelOption('📚', 'Reading', Colors.green),
    WheelOption('🎵', 'Music', Colors.orange),
    WheelOption('🏃', 'Sports', Colors.red),
    WheelOption('🎨', 'Art', Colors.purple),
    WheelOption('🍳', 'Cooking', Colors.teal),
    WheelOption('✈️', 'Travel', Colors.indigo),
    WheelOption('📱', 'Tech', Colors.pink),
  ];

  final List<Message> messages = [];

  final TextEditingController _messageController = TextEditingController();
  bool _showWheel = false;
  final responseMessageBuff = StringBuffer();
  String newResponseId = '';
  String responseMs = '>';
  String? sessionId;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleTemplateSelected(MessageTemplate template) {
    setState(() {
      _messageController.text = template.text;
      _showWheel = false;
    });
  }

  Future _handleSendMessage() async {
    var newMessage = _messageController.text.trim();
    print(newMessage);
    if (newMessage.isEmpty) return;

    var message = Message(
      id: const Uuid().v4(),
      content: newMessage,
      sender: 'User',
      sessionId: sessionId,
    );

    sessionId = await sendDeferredMessage(message);

    newResponseId = const Uuid().v4();

    var deferredResponse = Message(
      id: newResponseId,
      content: '...',
      sender: 'Assistant',
      sessionId: sessionId,
    );

    setState(() {
      messages.add(message);
      messages.add(deferredResponse);
    });

    // start listening for responses
    if (sessionId != null) {
      responseMessageBuff.clear();
      responseMs = '';
      receiveDeferredMessages(sessionId!).listen((response) {
        responseMessageBuff.write(response.replaceAll('\n', ''));
        setState(() {
          responseMs = responseMessageBuff.toString();
          deferredResponse.content = responseMs;
        });
      }, cancelOnError: true);
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat'), backgroundColor: Colors.blue),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, idx) {
                    final message = messages[idx];
                    return Row(
                      mainAxisAlignment: message.sender != 'User'
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 300,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: messages[idx].sender != 'User'
                                  ? Colors.blue[100]
                                  : Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                message.id == newResponseId
                                    ? responseMs
                                    : message.content,
                                textAlign: message.sender != 'User'
                                    ? TextAlign.start
                                    : TextAlign.end,
                              ),
                              subtitle: Text(
                                DateFormat.yMMMd().format(DateTime.now()),
                                textAlign: message.sender == 'User A'
                                    ? TextAlign.start
                                    : TextAlign.end,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _showWheel = true;
                        });
                      },
                      onTap: () {
                        _handleSendMessage();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showWheel)
            Center(
              child: SizedBox(
                height: 320,
                width: 320,
                child: WheelSelector(
                  options: options,
                  selectedIndex: 0,
                  onOptionSelected: (index, action) {
                    _messageController.text = options[index].label;
                    setState(() {
                      _showWheel = false;
                    });
                  },
                  onDismiss: () {
                    setState(() {
                      _showWheel = false;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
