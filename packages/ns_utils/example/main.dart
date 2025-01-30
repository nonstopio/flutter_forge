import 'package:flutter/material.dart';
import 'package:ns_utils/src.dart';
import 'package:ns_utils/widgets/custom_error_widget.dart';

void main() {
  //<editor-fold desc="Override ErrorWidget">
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return CustomErrorWidget(
      errorDetails: errorDetails,
      logoAsset: '<Your app logo asset>',
      showErrorDetails: true, //this should be set to false in production
      onRestart: (BuildContext context) {
        context.makeFirst(const HomeScreen());
      },
    );
  };
  //</editor-fold>

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
