import 'package:flutter/cupertino.dart';
import 'package:ns_firebase_utils/src.dart';

void main() async {
  await NSFirebase.instance.init(
    printLogs: true,
    buildNumber: '1.0.0',
    version: '1.0.0',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
