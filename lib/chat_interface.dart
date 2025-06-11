import 'package:flutter/material.dart';
import 'package:flutter_joystick/wheel_page.dart';

import '../models/message_template.dart';
// import 'message_wheel.dart';

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
  final TextEditingController _messageController = TextEditingController();
  bool _showWheel = false;

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

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // TODO: Implement message sending
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
                child: ListView(
                  // TODO: Implement message list
                  children: const [],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder()),
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
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(24)),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showWheel)
            // Consumer<TemplateProvider>(
            //   builder: (context, provider, child) {
            //     return MessageWheel(
            //       templates: provider.templates,
            //       onTemplateSelected: _handleTemplateSelected,
            //       onDismiss: () {
            //         setState(() {
            //           _showWheel = false;
            //         });
            //       },
            //     );
            //   },
            // ),
            Center(
              child: SizedBox(
                height: 320,
                width: 320,
                child: WheelSelector(
                  options: options,
                  selectedIndex: 0,
                  onOptionSelected: (index, action) {
                    print(index);
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
