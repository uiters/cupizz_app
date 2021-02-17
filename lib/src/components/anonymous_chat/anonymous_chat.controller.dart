import 'dart:async';

import 'package:cupizz_app/src/base/base.dart';

import 'anonymous_chat.model.dart';

class AnonymousChatController extends MomentumController<AnonymousChatModel> {
  StreamSubscription<Conversation> findChatSupscription;

  @override
  AnonymousChatModel init() {
    return AnonymousChatModel(this);
  }

  @override
  Future<void> bootstrapAsync() async {
    await _getMyAnonymousChat();
    return super.bootstrapAsync();
  }

  void findAnonymousChat() {
    if (model.conversation != null) {
      Fluttertoast.showToast(
          msg:
              'Không thể bắt đầu một cuộc trò chuyện mới, hãy kết thúc cuộc trò chuyện hiện tại trước.');
      return;
    }
    model.update(isFinding: true);
    findChatSupscription =
        Get.find<MessageService>().findAnonymousChat().listen((conversation) {
      model.update(
        conversation: conversation,
        isFinding: false,
      );
    });
  }

  Future loadMoreMessage() async {
    if (model.conversation == null) return;
    await Get.find<MessageService>().getMessages(
        key: ConversationKey(conversationId: model.conversation.id));
  }

  Future _getMyAnonymousChat() async {
    final conversation = await Get.find<MessageService>().getMyAnonymousChat();
    model.update(conversation: conversation);
  }
}
