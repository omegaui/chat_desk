import 'dart:convert';

class Message {
  final String id;
  final String type;
  final String sender;
  final dynamic message;
  final String receiver;
  final String time;

  Message(
      {required this.id,
      required this.type,
      required this.time,
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
      "id": id,
      "type": type,
      "sender": sender,
      "message": message,
      "receiver": receiver,
      "time": time
    });
  }

  static Message fromJSON(dynamic data) {
    return Message(
        id: data['id'],
        type: data['type'],
        sender: data["sender"],
        message: data["message"],
        receiver: data["receiver"],
        time: data['time']);
  }
}
