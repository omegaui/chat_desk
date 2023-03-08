import 'dart:convert';

const initError = 101;
const initSuccess = 102;
const connectionRefused = 103;
const connectionEstablished = 100;
const clientJoined = 104;
const clientExited = 105;
const unauthorized = 111;
const userAlreadyExist = 200;
const fetchMessages = 201;
const chatSwitched = 301;
const chatCompanion = 302;
const serverClosing = -1;

void streamLog(int code, String message) {
  print(createResponse(code, message));
}

String createResponse(int code, dynamic response, {dynamic cause}) {
  return jsonEncode({
    "type": "server-response",
    "code": code,
    "message": response,
    "cause": cause
  });
}

String createMessage(String receiver, dynamic message, String type, String id) {
  return jsonEncode(
      {"type": type, "message": message, "receiver": receiver, "id": id});
}

String sendMessage(String sender, dynamic message, String type, String id) {
  return jsonEncode(
      {"type": type, "message": message, "sender": sender, "id": id});
}

String createRequest(int requestCode, String id) {
  return jsonEncode({"type": "client-request", "id": id, "code": requestCode});
}
