import 'dart:convert';
import 'dart:io';
import 'package:chat_desk/core/io/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Client {
  String id;
  String description;
  String code;
  String avatar;
  late WebSocketChannel channel;

  Client(
      {required this.id,
      required this.description,
      required this.code,
      required this.avatar});

  void connect(String host, int port, Function(dynamic) listener) {
    channel = WebSocketChannel.connect(
        Uri.parse("ws://$host:$port/connect/${toString()}"));
    channel.stream.listen(listener);
  }

  void transmit(String receiver, String message) {
    channel.sink.add(createMessage(receiver, message));
  }

  void request(dynamic data) {
    channel.sink.add(data);
  }

  void notifyChange(dynamic data) {
    channel.sink.add(data);
  }

  @override
  String toString() {
    return jsonEncode(
        {"id": id, "description": description, "avatar": avatar, "code": code});
  }

  bool authenticate(String code) {
    return this.code == code;
  }

  static Client fromParameter(String clientData) {
    dynamic data = jsonDecode(Uri.decodeFull(clientData));
    return fromJson(data);
  }

  static Client fromJson(dynamic data) {
    return Client(
      id: data["id"],
      description: data["description"],
      code: data["code"],
      avatar: data["avatar"],
    );
  }
}

void main() {
  Client(
          id: "corpus",
          description: "Just Another User",
          code: "code",
          avatar: base64UrlEncode(
              File("/home/omegaui/Downloads/icons8-package-94.png")
                  .readAsBytesSync()))
      .connect("127.0.0.1", 8080, (p0) {});
  Client(
          id: "zeno",
          description: "Just Another User",
          code: "code",
          avatar: base64UrlEncode(
              File("/home/omegaui/Downloads/icons8-kawaii-shellfish-96.png")
                  .readAsBytesSync()))
      .connect("127.0.0.1", 8080, (p0) {});
  // Client(
  //     id: "_mike",
  //     description: "Just Another User",
  //     code: "code",
  //     avatar: base64UrlEncode(File("/home/omegaui/Downloads/icons8-markdown-100.png").readAsBytesSync())
  // ).connect("127.0.0.1", 8080, (p0) {
  //
  // });Client(
  //     id: "pluto",
  //     description: "Just Another User",
  //     code: "code",
  //     avatar: base64UrlEncode(File("/home/omegaui/Downloads/icons8-kawaii-shellfish-96.png").readAsBytesSync())
  // ).connect("127.0.0.1", 8080, (p0) {
  //
  // });
  //
  // Client(
  //     id: "john",
  //     description: "Just Another User",
  //     code: "code",
  //     avatar: base64UrlEncode(File("/home/omegaui/Downloads/icons8-kawaii-shellfish-96.png").readAsBytesSync())
  // ).connect("127.0.0.1", 8080, (p0) {
  //
  // });
  //
  // var client = Client(
  //     id: "blaze",
  //     description: "Just Another User",
  //     code: "code",
  //     avatar: base64UrlEncode(
  //         File("/home/omegaui/Downloads/icons8-linux-96.png")
  //             .readAsBytesSync()))
  //   ..connect("127.0.0.1", 8080, (p0) {
  //     print(p0);
  //   });
  //
  // Future.delayed(const Duration(seconds: 4), () async {
  //   client.transmit("omegaui", "hello");
  //   client.transmit("omegaui", "What are you doing?");
  // });

  // Future.delayed(const Duration(seconds: 4), () async {
  //   client.request(jsonEncode({
  //     "type": "request",
  //     "code": fetchMessages,
  //     "with-id": "john"
  //   }));
  // });
}
