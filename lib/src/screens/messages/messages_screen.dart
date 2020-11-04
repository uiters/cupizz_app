library messages_screen;

import 'package:flutter/material.dart' hide Router;
import '../../base/base.dart';
import '../../widgets/index.dart';
import '../../packages/dash_chat/dash_chat.dart';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      body: DashChat(
        user: ChatUser(
          name: "Hien",
          uid: "001",
          avatar:
              "https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg",
        ),
        messages: [
          ChatMessage(
              text: 'Welcome', user: ChatUser(uid: '002', name: 'Cupid')),
        ],
        onSend: (ChatMessage message) {},
      ),
    );
  }
}
