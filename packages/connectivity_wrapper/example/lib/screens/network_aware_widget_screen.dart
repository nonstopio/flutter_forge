import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:connectivity_wrapper_example/utils/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/ui_helper.dart';

class NetworkAwareWidgetScreen extends StatelessWidget {
  const NetworkAwareWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.example3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          const TextField(
            decoration: InputDecoration(labelText: 'Email'),
          ),
          const SizeGap(),
          const TextField(
            decoration: InputDecoration(labelText: 'Password'),
          ),
          const SizeGap(),
          ConnectivityWidgetWrapper(
            stacked: false,
            offlineWidget: ElevatedButton(
              onPressed: null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.grey),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Connecting",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    SizeGap(),
                    CupertinoActivityIndicator(radius: 8.0),
                  ],
                ),
              ),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              child: const Text(
                "Sign In",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
