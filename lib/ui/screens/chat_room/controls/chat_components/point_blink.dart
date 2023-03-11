import 'package:flutter/material.dart';

class PointBlink extends StatefulWidget {
  const PointBlink({super.key});

  @override
  State<PointBlink> createState() => _PointBlinkState();
}

class _PointBlinkState extends State<PointBlink>
    with SingleTickerProviderStateMixin<PointBlink> {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    controller.forward();
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: 20 * controller.value,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.greenAccent,
          ),
        );
      },
    );
  }
}
