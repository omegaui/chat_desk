import 'dart:convert';

class Message {
  final String sender;
  final dynamic message;
  final String receiver;
  final String time;

  Message(
      {required this.time,
      required this.sender,
      required this.message,
      required this.receiver});

  bool between(String sender, String receiver) {
    return (this.sender == sender && this.receiver == receiver) ||
        (this.sender == receiver && this.receiver == sender);
  }

  @override
  String toString() {
    return jsonEncode({
      "sender": sender,
      "message": message,
      "receiver": receiver,
      "time": time
    });
  }

  static Message fromJSON(dynamic data) {
    return Message(
        sender: data["sender"],
        message: data["message"],
        receiver: data["receiver"],
        time: data['time']);
  }
}
