import 'dart:async';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/models/message.dart';
import 'package:flutter_joystick/services/chat_service.dart';
import 'package:flutter_joystick/wheel_page.dart';
import 'package:uuid/uuid.dart';

class ChatInterface extends StatefulWidget {
  const ChatInterface({super.key});

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final List<WheelOption> options = [
    WheelOption(Icons.cancel, 'None', Colors.grey),
    WheelOption(Icons.face, 'Happy', Colors.green),
    WheelOption(Icons.face_2, 'Warmed up', Colors.orange),
    WheelOption(Icons.emoji_emotions, 'Angry', Colors.red),
  ];

  final List<Message> messages = [];

  final TextEditingController _messageController = TextEditingController();
  final textInputDebouncer = Debouncer<String>(
    Duration(milliseconds: 500),
    initialValue: '',
  );
  Timer? _debounceMessageChange;

  final _listViewScrollController = ScrollController();

  bool _showWheel = false;
  final responseMessageBuff = StringBuffer();
  String newResponseId = '';
  String responseMs = '...';
  String? sessionId;
  final targetSentiment = ValueNotifier<String?>(null);
  String? revisedMessage;
  String? lastInput;

  bool _showSuggestion = false;

  @override
  void initState() {
    super.initState();
    lastInput = _messageController.text;

    _messageController.addListener(() {
      textInputDebouncer.value = _messageController.text;
    });

    textInputDebouncer.values.listen((value) {
      if (_messageController.text == lastInput) return;
      if (_messageController.text == revisedMessage) return;

      print('input changed');
      onInputChanged();

      lastInput = _messageController.text;
    });

    targetSentiment.addListener(() {
      if (targetSentiment.value == null) return;

      print('sentiment changed');
      onInputChanged();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    targetSentiment.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _listViewScrollController.animateTo(
      _listViewScrollController.position.maxScrollExtent,
      duration: Duration(microseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void onInputChanged() async {
    setState(() {
      revisedMessage = null;
      _showSuggestion = false;
    });

    final input = _messageController.text;

    print('Sent for supervisory');

    var revise = await sendForRevisory(
      Message(
        id: Uuid().v4(),
        content: input,
        sender: 'User',
        extraSystemPrompt: targetSentiment.value,
      ),
    );

    setState(() {
      revisedMessage = revise;
      _showSuggestion = true;
    });
  }

  Future _handleSendMessage() async {
    var newMessage = _messageController.text.trim();
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
        _scrollToBottom();
      }, cancelOnError: true);
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat'), backgroundColor: Colors.blue),
      body: LayoutBuilder(
        builder: (ctx, constraint) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _listViewScrollController,
                      itemCount: messages.length,
                      itemBuilder: (listViewContext, idx) {
                        final message = messages[idx];
                        return Row(
                          mainAxisAlignment: message.sender != 'User'
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraint.maxWidth * 0.8,
                              ),
                              child: IntrinsicWidth(
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          message.id == newResponseId
                                              ? responseMs
                                              : message.content,
                                          textAlign: message.sender != 'User'
                                              ? TextAlign.start
                                              : TextAlign.end,
                                        ),
                                      ),
                                    ],
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
                    child: Column(
                      children: [
                        if (_showSuggestion)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _messageController.text = revisedMessage!;
                                      _showSuggestion = false;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow[50],
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 4,
                                          offset: const Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 11,
                                          child: Text(
                                            revisedMessage ?? '',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ),
                                        Spacer(flex: 1),
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (revisedMessage != null) SizedBox(height: 10),
                        Row(
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
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
                      selectedIndex: -1,
                      onOptionSelected: (index, action) {
                        // set the target sentiment
                        setState(() {
                          _showWheel = false;
                          if (index > 0) {
                            targetSentiment.value =
                                "Target sentiment: ${options[index].label}\n";
                          } else {
                            targetSentiment.value = null;
                          }
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
          );
        },
      ),
    );
  }
}
