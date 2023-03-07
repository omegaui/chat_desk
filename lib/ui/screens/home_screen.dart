import 'dart:io';

import 'package:chat_desk/core/io/app_manager.dart';
import 'package:chat_desk/core/io/logger.dart';
import 'package:chat_desk/core/server/server.dart';
import 'package:chat_desk/io/server_handler.dart';
import 'package:chat_desk/main.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:string_validator/string_validator.dart' as text_validator;

GlobalKey<StatusBarState> statusBarKey = GlobalKey();
bool connectedToServer = false;

void setStatus(String message, Color color) {
  statusBarKey.currentState?.setStatus(message, color);
}

bool validIP = true;
bool validPort = true;
bool validCode = true;

final TextEditingController ipController = TextEditingController();
final TextEditingController portController = TextEditingController();
final TextEditingController codeController = TextEditingController();

TextEditingController usernameController =
    TextEditingController(text: AppManager.getUsername());
TextEditingController descriptionController =
    TextEditingController(text: AppManager.getDescription());

bool validUsername = true;
bool validDescription = true;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset('assets/lottie-animations/server-animation.json',
            width: 500),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Expanded(child: UserSettings()),
            Expanded(child: ConnectionConsole()),
          ],
        ),
      ],
    );
  }
}

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppUtils.buildTooltip(
          text: "Click to change Avatar",
          child: const Avatar(),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return SizedBox(
                  width: 200,
                  child: TextField(
                    controller: usernameController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Sen",
                      fontSize: 18,
                    ),
                    cursorColor: Colors.greenAccent,
                    decoration: InputDecoration(
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.greenAccent)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.greenAccent, width: 3)),
                      errorBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.redAccent, width: 2)),
                      errorText: validUsername
                          ? null
                          : "Username must include characters from a-z, 0-1, \$ or _.\nAt least 5 and at most 16 characters long.",
                      errorStyle: const TextStyle(
                          fontFamily: "Itim", fontWeight: FontWeight.bold),
                      errorMaxLines: 4,
                      hintText: "Enter your username",
                      hintStyle:
                          const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onChanged: (value) async {
                      value = value.trim();
                      if (value.length < 5 || value.length > 16) {
                        setState(() => validUsername = false);
                        return;
                      }
                      bool valid = true;
                      for (var char in value.characters) {
                        if (text_validator.isAlpha(char)) {
                          if (text_validator.isUppercase(char)) {
                            valid = false;
                            break;
                          }
                        } else if (!text_validator.isInt(char)) {
                          if (!['\$', '_'].contains(char)) {
                            valid = false;
                            break;
                          }
                        }
                      }
                      setState(() => validUsername = valid);
                      if (valid) {
                        await AppManager.preferences
                            .setString('username', value);
                      }
                    },
                  ),
                );
              },
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return SizedBox(
                  width: 200,
                  child: TextField(
                    controller: descriptionController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Sen",
                      fontSize: 14,
                    ),
                    cursorColor: Colors.greenAccent,
                    decoration: InputDecoration(
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyanAccent)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.cyanAccent, width: 3)),
                      errorBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.redAccent, width: 2)),
                      errorText: validDescription
                          ? null
                          : "Hey! Don't leave this empty.",
                      errorStyle: const TextStyle(
                          fontFamily: "Itim", fontWeight: FontWeight.bold),
                      errorMaxLines: 4,
                      hintText: "A thought or description of yours",
                      hintStyle:
                          const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    onChanged: (value) async {
                      value = value.trim();
                      setState(() => validDescription = value.isNotEmpty);
                      if (value.isNotEmpty) {
                        await AppManager.preferences
                            .setString('description', value);
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ConnectionConsole extends StatelessWidget {
  const ConnectionConsole({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Connect to a Server",
            style: TextStyle(color: Colors.grey.shade200, fontSize: 32),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return TextField(
                          controller: ipController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "Sen",
                            fontSize: 18,
                          ),
                          cursorColor: Colors.greenAccent,
                          decoration: InputDecoration(
                            enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.greenAccent)),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.greenAccent, width: 3)),
                            errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.redAccent, width: 2)),
                            hintText: "Enter IP Address",
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontFamily: "Sen",
                              fontSize: 16,
                            ),
                            errorText: validIP ? null : "Invalid IP Address",
                            errorStyle: const TextStyle(
                                fontFamily: "Itim",
                                fontWeight: FontWeight.bold),
                          ),
                          onChanged: (value) {
                            List<String> points = value.split('.');
                            if (points.length == 4 &&
                                points.where((source) {
                                      int? value = int.tryParse(source);
                                      if (value != null) {
                                        return value >= 0 && value <= 255;
                                      }
                                      return false;
                                    }).length ==
                                    4) {
                              setState(() => validIP = true);
                              return;
                            }
                            setState(() => validIP = false);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: NetworkInfo().getWifiIP(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.yellowAccent.shade700,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Text(
                                "Can't get Public IP!",
                                style: TextStyle(
                                    fontFamily: "Sen",
                                    fontSize: 14,
                                    color: Colors.red.shade400),
                              );
                            }
                            return GestureDetector(
                              onTap: () =>
                                  ipController.text = snapshot.data as String,
                              child: AppUtils.buildTooltip(
                                text: "Your Public IP",
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.yellowAccent.shade700,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      "${snapshot.data}",
                                      style: TextStyle(
                                          fontFamily: "Sen",
                                          fontSize: 16,
                                          color: Colors.grey.shade900),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => ipController.text = "127.0.0.1",
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              "localhost",
                              style: TextStyle(
                                  fontFamily: "Sen",
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 170,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return TextField(
                      controller: portController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Sen",
                        fontSize: 18,
                      ),
                      cursorColor: Colors.cyanAccent,
                      decoration: InputDecoration(
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.cyanAccent, width: 3)),
                        errorBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2)),
                        hintText: "Enter Port number",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Sen",
                          fontSize: 18,
                        ),
                        errorText: validPort ? null : "Invalid Port",
                        errorStyle: const TextStyle(
                            fontFamily: "Itim", fontWeight: FontWeight.bold),
                      ),
                      onChanged: (value) {
                        setState(
                            () => validPort = (int.tryParse(value) != null));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 170,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return TextField(
                      controller: codeController,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Sen",
                        fontSize: 18,
                      ),
                      cursorColor: Colors.tealAccent,
                      decoration: InputDecoration(
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.tealAccent, width: 3)),
                        errorBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2)),
                        hintText: "Enter Server Code",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Sen",
                          fontSize: 18,
                        ),
                        errorText: validCode ? null : "**Required",
                        errorStyle: const TextStyle(
                            fontFamily: "Itim", fontWeight: FontWeight.bold),
                      ),
                      onChanged: (value) {
                        setState(() => validCode = value.trim().isNotEmpty);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Wrap(
            spacing: 10,
            children: const [
              JoinButton(),
              HostButton(),
            ],
          ),
        ),
        StatusBar(key: statusBarKey),
      ],
    );
  }
}

class JoinButton extends StatefulWidget {
  const JoinButton({super.key});

  @override
  State<JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends State<JoinButton> {
  bool hover = false;
  bool connecting = false;

  Future<void> tryToConnect(BuildContext context) async {
    if (ipController.text.isNotEmpty && portController.text.isNotEmpty) {
      if (validIP && validPort) {
        setState(() {
          connecting = true;
        });
        if (!(await doesServerExists(
            ipController.text, int.parse(portController.text)))) {
          setStatus("Server doesn't exists!", Colors.red.shade300);
          setState(() {
            connecting = false;
          });
        } else {
          if (connectedToServer) {
            setStatus("Already Joined! Click the blue dot above.",
                Colors.teal.shade300);
            return;
          }
          joinServer(
            ipController.text,
            int.parse(portController.text),
            onJoinError: (response) {
              setState(() {
                connecting = false;
              });
              if (response['cause'] == unauthorized) {
                setStatus("Invalid Server Code", Colors.red.shade300);
              } else if (response['cause'] == userAlreadyExist) {
                setStatus("User Already Exists!", Colors.teal.shade300);
              }
            },
            onJoinSuccess: (host, port) {
              connectedToServer = true;
              Future.delayed(
                  const Duration(milliseconds: 1500), () => push(chatRoom));
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: connecting
          ? const CircularProgressIndicator(
              color: Colors.blueGrey,
              backgroundColor: Colors.blue,
            )
          : MouseRegion(
              onEnter: (e) => setState(() => hover = true),
              onExit: (e) => setState(() => hover = false),
              child: GestureDetector(
                onTap: () async => await tryToConnect(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                    border: hover
                        ? null
                        : Border.all(
                            color: Colors.grey.shade700
                                .withOpacity(hover ? 1.0 : 0.3),
                            width: 2),
                    boxShadow: hover
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(9, 9),
                            ),
                            BoxShadow(
                              color: Colors.tealAccent.withOpacity(0.09),
                              blurRadius: 16,
                              offset: const Offset(-9, -9),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      "Join",
                      style: TextStyle(
                          fontFamily: "Sen",
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 22),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class HostButton extends StatefulWidget {
  const HostButton({super.key});

  @override
  State<HostButton> createState() => _HostButtonState();
}

class _HostButtonState extends State<HostButton> {
  bool hover = false;
  bool connecting = false;

  Future<void> tryToConnect(BuildContext context) async {
    if (ipController.text.isNotEmpty && portController.text.isNotEmpty) {
      if (validIP && validPort) {
        setState(() {
          connecting = true;
        });
        if (await doesServerExists(
            ipController.text, int.parse(portController.text))) {
          setStatus("Server already running!", Colors.red.shade300);
          setState(() {
            connecting = false;
          });
        } else {
          await hostServer(ipController.text, int.parse(portController.text),
              codeController.text, onStartFailed: () {
            setStatus("Server Launch Failed", Colors.red);
          }, onStartComplete: () {
            setStatus("Server Started Successfully!", Colors.blue);
            joinServer(
              ipController.text,
              int.parse(portController.text),
              onJoinError: (response) {
                setState(() {
                  connecting = false;
                });
                if (response['cause'] == unauthorized) {
                  setStatus("Invalid Server Code", Colors.red.shade300);
                } else if (response['cause'] == userAlreadyExist) {
                  setStatus(
                      "User already entered the server!", Colors.teal.shade300);
                }
              },
              onJoinSuccess: (host, port) {
                connectedToServer = true;
                Future.delayed(
                    const Duration(milliseconds: 1500), () => push(chatRoom));
              },
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: connecting
          ? const CircularProgressIndicator(
              color: Colors.blueGrey,
              backgroundColor: Colors.pinkAccent,
            )
          : MouseRegion(
              onEnter: (e) => setState(() => hover = true),
              onExit: (e) => setState(() => hover = false),
              child: GestureDetector(
                onTap: () async => await tryToConnect(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                    border: hover
                        ? null
                        : Border.all(
                            color: Colors.grey.shade700
                                .withOpacity(hover ? 1.0 : 0.3),
                            width: 2),
                    boxShadow: hover
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(9, 9),
                            ),
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.09),
                              blurRadius: 16,
                              offset: const Offset(-9, -9),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      "Host",
                      style: TextStyle(
                          fontFamily: "Sen",
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 22),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class Avatar extends StatefulWidget {
  const Avatar({super.key});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool hover = false;

  void pickAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        dialogTitle: "Pick a profile image",
        type: FileType.image,
        lockParentWindow: true);
    if (result != null) {
      await AppManager.preferences
          .setString('avatar', result.paths.first as String);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String? avatar = AppManager.getAvatar();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MouseRegion(
        onEnter: (e) => setState(() => hover = true),
        onExit: (e) => setState(() => hover = false),
        child: GestureDetector(
          onTap: pickAvatar,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.2),
              borderRadius: BorderRadius.circular(1000),
              boxShadow: hover
                  ? [
                      BoxShadow(
                        color: Colors.grey.shade800.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(-9, -9),
                      ),
                      BoxShadow(
                        color: Colors.grey.shade800.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(9, 9),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.shade800.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(-9, -9),
                      ),
                      BoxShadow(
                        color: Colors.grey.shade800.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(9, 9),
                      ),
                    ],
            ),
            child: avatar != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(File(avatar)),
                  )
                : Icon(
                    Icons.person_rounded,
                    size: 80,
                    color: Colors.grey.shade600,
                  ),
          ),
        ),
      ),
    );
  }
}

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => StatusBarState();
}

class StatusBarState extends State<StatusBar> {
  String message = "";
  Color color = Colors.blueAccent;
  double opacity = 0;

  void setStatus(String message, Color color) {
    setState(() {
      this.message = message;
      this.color = color;
      opacity = 1.0;
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => opacity = 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            message,
            style: TextStyle(
                fontFamily: "Sen",
                color: Colors.grey.shade900,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
