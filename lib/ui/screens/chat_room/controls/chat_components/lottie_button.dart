import 'package:chat_desk/io/app_style.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieButton extends StatefulWidget {
  const LottieButton({
    super.key,
    required this.onPressed,
    required this.lottieAnimationPath,
  });

  final VoidCallback onPressed;
  final String lottieAnimationPath;

  @override
  State<LottieButton> createState() => _LottieButtonState();
}

class _LottieButtonState extends State<LottieButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => hover = true),
      onExit: (e) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: hover
                ? Colors.grey.withOpacity(0.2)
                : (currentStyleMode == AppStyle.dark
                    ? Colors.grey.shade800
                    : Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(40),
          ),
          padding: EdgeInsets.all(hover ? 2 : 12),
          child: Lottie.asset(
            widget.lottieAnimationPath,
          ),
        ),
      ),
    );
  }
}
