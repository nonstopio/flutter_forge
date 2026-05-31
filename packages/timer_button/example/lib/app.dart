import 'package:flutter/material.dart';

import 'home_page.dart';
import 'theme.dart';

class TimerButtonApp extends StatelessWidget {
  const TimerButtonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer Button Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
