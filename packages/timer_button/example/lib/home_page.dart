import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:timer_button/timer_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Button Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TimerButton(
                label: 'Try Again',
                timeOutInSeconds: 5,
                onPressed: () {
                  log('Time for some action!');
                },
              ),
              TimerButton(
                label: 'Outlined: Try Again',
                timeOutInSeconds: 5,
                onPressed: () {},
                buttonType: ButtonType.outlinedButton,
                disabledColor: colorScheme.error,
                color: colorScheme.primary,
                activeTextStyle: TextStyle(color: colorScheme.primary),
                disabledTextStyle: TextStyle(color: colorScheme.error),
              ),
              TimerButton(
                label: 'Text: Try Again',
                timeOutInSeconds: 5,
                onPressed: () {
                  log('Time for some action!');
                },
                timeUpFlag: true,
                buttonType: ButtonType.textButton,
                disabledColor: colorScheme.errorContainer,
                color: colorScheme.primaryContainer,
              ),
              TimerButton.builder(
                builder: (context, timeLeft) {
                  return Text(
                    'Custom: $timeLeft',
                    style: TextStyle(color: colorScheme.tertiary),
                  );
                },
                onPressed: () {
                  log('Time for some action!');
                },
                timeOutInSeconds: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
