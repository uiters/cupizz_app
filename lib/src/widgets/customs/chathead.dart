import 'package:cupizz_app/src/assets.dart';
import 'package:cupizz_app/src/base/base.dart';
import 'package:floaty_head/floaty_head.dart';

class ChatHead {
  static final _instance = ChatHead._();
  ChatHead._() {
    _setNotificationIcon();
  }
  factory ChatHead() => _instance;

  final _floatyHead = FloatyHead();
  final List<Conversation> conversations = [];
  int selectedIndex;

  void addChat(Conversation conversation) {
    conversations.add(conversation);
    _setIcon(conversation);
    _floatyHead.openBubble();
  }

  void closeChat(Conversation conversation) {
    conversations.remove(conversation);
  }

  void selectChat(Conversation conversation) {}

  Future _setNotificationIcon() async {
    await _floatyHead.setNotificationIcon(Assets.i.images.logo);
  }

  Future _setIcon(Conversation conversation) async {
    await _floatyHead.setIcon(Assets.i.images.logo);
  }
}
