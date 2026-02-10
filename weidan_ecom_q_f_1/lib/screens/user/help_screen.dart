import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _addBotMessage("Hi! I'm your AI assistant. How can I help you today?");
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    String userMessage = _messageController.text.trim();
    _addUserMessage(userMessage);
    _messageController.clear();
    
    // Simulate AI response
    Future.delayed(Duration(milliseconds: 500), () {
      _addBotMessage(_generateResponse(userMessage));
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(message: message, isUser: true));
    });
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(message: message, isUser: false));
    });
  }

  String _generateResponse(String userMessage) {
    String message = userMessage.toLowerCase();
    
    if (message.contains('order') || message.contains('delivery')) {
      return "You can track your orders in the Order History section. Orders are typically delivered within 3-5 business days.";
    } else if (message.contains('return') || message.contains('refund')) {
      return "We offer 30-day returns on all items. Please contact our support team to initiate a return.";
    } else if (message.contains('payment') || message.contains('card')) {
      return "We accept all major credit cards and PayPal. Your payment information is secure and encrypted.";
    } else if (message.contains('size') || message.contains('sizing')) {
      return "Check our size guide in the product details. If you're unsure, we recommend ordering your usual size.";
    } else if (message.contains('shipping') || message.contains('delivery')) {
      return "We offer free shipping on orders over \$50. Standard delivery takes 3-5 business days.";
    } else {
      return "I'm here to help! You can ask me about orders, returns, payments, sizing, or shipping. What would you like to know?";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: message.isUser ? null : Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.grey[600], size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;

  ChatMessage({required this.message, required this.isUser});
}