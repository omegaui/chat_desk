// Tests for server

import 'package:chat_desk/core/client/client.dart';
import 'package:chat_desk/core/server/server.dart';
import 'package:chat_desk/io/server_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Server Initialization Test", () async {
    await hostServer("127.0.0.1", 8080, "test", onStartComplete: () {}, onStartFailed: () {});

    // Waiting for Server Warm up
    await Future.delayed(const Duration(seconds: 2));

    // Checking if it is alive
    bool isAlive = await doesServerExists('127.0.0.1', 8080);
    expect(isAlive, true);
  });

  test("Server Close Request Test", () async {
    // Checking if it is alive
    bool isAlive = await doesServerExists('127.0.0.1', 8080);
    expect(isAlive, true);

    // Joining the server
    thisClient = Client(
      id: "test-user",
      description: "this is a test user",
      code: "test",
      avatar: "",
    );

    thisClient.connect(host, port, (message) {});

    // Server Handler should exist at this point
    expect(serverHandler, isNotNull);
    serverHandler!.requestClose();

    // Waiting for Server to process request
    await Future.delayed(const Duration(seconds: 1));

    bool isDead = !(await doesServerExists('127.0.0.1', 8080));
    expect(isDead, true);
  });
}
