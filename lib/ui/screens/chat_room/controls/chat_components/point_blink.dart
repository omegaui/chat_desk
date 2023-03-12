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
      duration: const Duration(seconds: 2),
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
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Container(
              width: 30 * controller.value,
              height: 30 * controller.value,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(1 - controller.value),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  width: 20 * controller.value,
                  height: 20 * controller.value,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(1 - controller.value),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Container(
                      width: 10 * controller.value,
                      height: 10 * controller.value,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(controller.value),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
