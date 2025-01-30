import 'package:contact_permission/contact_permission.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isPermissionGranted;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isPermissionGranted != null)
              _isPermissionGranted!
                  ? const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 100,
                    )
                  : const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 100,
                    ),
            Text('Permission granted: $_isPermissionGranted'),
            ElevatedButton(
              onPressed: () async {
                final result = await ContactPermission.isPermissionGranted();
                setState(() {
                  _isPermissionGranted = result;
                });
                debugPrint('Permission granted: $_isPermissionGranted');
              },
              child: const Text('Check Permission'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await ContactPermission.requestPermission();
                setState(() {
                  _isPermissionGranted = result;
                });
                debugPrint('Permission granted: $_isPermissionGranted');
              },
              child: const Text('Request Permission'),
            ),
          ],
        )),
      ),
    );
  }
}
