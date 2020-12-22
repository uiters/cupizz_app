part of '../messages_screen.dart';

enum ChatPageEventAction {
  error,
}

class ChatPageEvent {
  final ChatPageEventAction action;
  final String message;

  ChatPageEvent({@required this.action, this.message});
}

class MessagesScreenController extends MomentumController<MessagesScreenModel> {
  StreamSubscription<Message> messageSupscription;

  @override
  MessagesScreenModel init() {
    return MessagesScreenModel(this);
  }

  @override
  Future bootstrapAsync() async {
    if (model.conversation?.id != null) {
      await loadData(ConversationKey(conversationId: model.conversation?.id));
    }
  }

  Future loadData(ConversationKey key) async {
    model.update(isLoading: true);
    await _reload(key: key);
    subscribe(key);
    model.update(isLoading: false);
  }

  @override
  void reset({bool clearHistory}) {
    messageSupscription?.cancel();
    messageSupscription = null;
    debugPrint('Unsubscribed conversation');
    super.reset(clearHistory: clearHistory);
  }

  Future refresh() => _reload();

  void onNewMessage(Message message) {
    model.messages.insert(0, message);
    model.update(messages: model.messages);
  }

  void sendMessage({String message, List<File> attachments}) async {
    try {
      model.update(isSendingMessage: true);
      await getService<MessageService>().sendMessage(
        ConversationKey(conversationId: model.conversation.id),
        message: message,
        attachments: attachments,
      );
    } catch (e) {
      unawaited(Fluttertoast.showToast(msg: e.toString()));
    } finally {
      model.update(isSendingMessage: false);
    }
  }

  Future loadmore() async {
    if (model.isLastPage) return;
    try {
      final data = await getService<MessageService>().getMessages(
        key: ConversationKey(conversationId: model.conversation?.id),
        page: model.currentPage + 1,
      );
      final messages = data.data;
      model.messages.addAll(messages);

      model.update(
        messages: model.messages,
        currentPage: model.currentPage + 1,
        isLastPage: data.isLastPage,
      );
    } catch (e) {
      sendEvent(ChatPageEvent(
          action: ChatPageEventAction.error, message: e.toString()));
    }
  }

  Future _reload({ConversationKey key}) async {
    try {
      if (key == null && model.conversation == null) {
        throw 'Missing screen params';
      }
      final messageService = getService<MessageService>();

      final futureRes = await Future.wait([
        messageService.getMessages(
          key: key ?? ConversationKey(conversationId: model.conversation?.id),
          page: 1,
        ),
        ...key != null ? [messageService.getConversation(key: key)] : []
      ]);

      final messagesData = futureRes[0];

      model.update(
        conversation: futureRes.length > 1 ? futureRes[1] : null,
        messages: messagesData.data,
        currentPage: 1,
        isLastPage: messagesData.isLastPage,
      );
    } catch (e) {
      sendEvent(ChatPageEvent(
          action: ChatPageEventAction.error, message: e.toString()));
    }
  }

  void subscribe(ConversationKey key) {
    if (messageSupscription == null && key != null) {
      messageSupscription =
          getService<MessageService>().onNewMessage(key).listen(onNewMessage);
      debugPrint('Subscribed conversation: $key');
    }
  }
}