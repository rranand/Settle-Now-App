// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';

class TimerButton extends StatefulWidget {
  final int timerDuration;
  final VoidCallback onPressed;

  const TimerButton({
    super.key,
    this.timerDuration = 30,
    required this.onPressed,
  });

  @override
  State<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  final ValueNotifier<int> _secondsRemaining = ValueNotifier(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining.value = widget.timerDuration;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining.value > 0) {
        _secondsRemaining.value -= 1;
      } else {
        timer.cancel();
      }
    });
  }

  void _onPressed() {
    _startTimer();
    widget.onPressed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _secondsRemaining,
      builder: (BuildContext context, int value, Widget? child) {
        return value == 0
            ? TextButton(
              onPressed: _onPressed,
              child: const Text(
                "Resend OTP",
                style: TextStyle(color: Colors.blue),
              ),
            )
            : Text(
              "Resend in $value sec",
              style: const TextStyle(color: Colors.grey),
            );
      },
    );
  }
}
