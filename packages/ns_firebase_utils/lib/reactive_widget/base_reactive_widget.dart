import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

typedef Widget DataWidgetBuilder<T>(T data);

class ReactiveRef<DataType> {
  final DocumentReference ref;

  ReactiveRef(this.ref);
}

class ReactiveWidget<DataType> extends StatelessWidget {
  final ReactiveRef<DataType> reactiveRef;
  final DataWidgetBuilder<DataType?> widgetBuilder;
  final DataType fallbackValue;
  final Widget? waitingWidget;

  ReactiveWidget({
    required this.reactiveRef,
    required this.widgetBuilder,
    required this.fallbackValue,
    this.waitingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<DataType?>(
      stream: reactiveRef.ref
          .snapshots()
          .map((DocumentSnapshot event) => event.data() as DataType?),
      builder: getReactiveBuilder<DataType?>(
        onData: widgetBuilder,
        onWaiting: waitingWidget,
        onFallback: widgetBuilder(fallbackValue),
      ),
    );
  }
}

AsyncWidgetBuilder<T> getReactiveBuilder<T>({
  required DataWidgetBuilder<T?> onData,
  required Widget onFallback,
  required Widget? onWaiting,
}) {
  return (BuildContext context, AsyncSnapshot<T> snapshot) {
    if (snapshot.hasData)
      return onData(snapshot.data);
    else
      switch (snapshot.connectionState) {
        case ConnectionState.active:
          return onFallback;
        default:
          if (snapshot.hasError)
            return onFallback;
          else
            return onWaiting ?? onFallback;
      }
  };
}
