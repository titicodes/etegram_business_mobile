import 'package:etegram_business/base/base_vm.dart';

import '../model/chat_message.dart';

class ProfileViewModel extends BaseViewModel {
  bool isEmailSelected = false;
  bool isPushNotificationSelected = false;

  void toggleEmailSwitch(bool value) {
    isEmailSelected = !isEmailSelected;
    notifyListeners();
  }

  void togglePushedNotificationSwitch(bool value) {
    isPushNotificationSelected = !isPushNotificationSelected;
    notifyListeners();
  }

  List<ChatMessage> messages = [
    ChatMessage(messageContent: "Hello, Will", messageType: "receiver"),
    ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
    ChatMessage(
        messageContent: "Hey Kriss, I am doing fine dude. wbu?",
        messageType: "sender"),
    ChatMessage(messageContent: "ehhhh, doing OK.", messageType: "receiver"),
    ChatMessage(
        messageContent: "Is there any thing wrong?", messageType: "sender"),
  ];
}
