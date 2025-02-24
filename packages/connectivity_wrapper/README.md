<p align="center">
  <a href="https://nonstopio.com">
    <img src="https://github.com/nonstopio.png" alt="Nonstop Logo" height="128" />
  </a>
  <h1 align="center">NonStop</h1>
  <p align="center">Digital Product Development Experts for Startups & Enterprises</p>
  <p align="center">
    <a href="https://nonstopio.com/about">About</a> |
    <a href="https://nonstopio.com">Website</a>
  </p>
</p>

# connectivity_wrapper

[![Build Status](https://img.shields.io/pub/v/connectivity_wrapper.svg)](https://github.com/nonstopio/flutter_forge/tree/main/packages/connectivity_wrapper)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This plugin allows Flutter apps provide feedback on your app when it's not connected to it, or when there's no connection.

## Requirements

- Flutter >=3.19.0
- Dart >=3.3.0 <4.0.0
- iOS >=12.0
- MacOS >=10.14
- Android `compileSDK` 34
- Java 17
- Android Gradle Plugin >=8.3.0
- Gradle wrapper >=8.4

## Usage

```dart
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
```

Check if device is connected to internet or not 

```dart
...

 onTap: () async {
        if (await ConnectivityWrapper.instance.isConnected) {
          showSnackBar(
            _scaffoldKey,
            title: "You Are Connected",
            color: Colors.green,
          );
        } else {
          showSnackBar(
            _scaffoldKey,
            title: "You Are Not Connected",
          );
        }
      },

...

```

# Create `Network` Aware Widgets

## Type 1: A common widget for the entire app
STEP 1: Wrap `MaterialApp/CupertinoApp` with `ConnectivityAppWrapper`

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectivityAppWrapper(
      app: MaterialApp(
        title: 'Connectivity Wrapper Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MenuScreen(),
        builder: (buildContext, widget) {
          return ConnectivityWidgetWrapper(
            child: widget,
            disableInteraction: true,
            height: 80,
          );
        },
      ),
    );
  }
}
```

## Type 2: Screen/widget specific widgets
STEP 1: Wrap `MaterialApp/CupertinoApp` with `ConnectivityAppWrapper`

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectivityAppWrapper(
      app: MaterialApp(
        title: 'Connectivity Wrapper Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MenuScreen(),
      ),
    );
  }
}
```

STEP 2: The last step, Wrap your body widget with `ConnectivityWidgetWrapper` or use [`ConnectivityScreenWrapper`](example/lib/screens/menu_screen.dart) for In-build animation

```dart

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connectivity Wrapper Example"),
      ),
      body: ConnectivityWidgetWrapper( // or use ##ConnectivityScreenWrapper for In build animation
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(Strings.example1),
              onTap: () {
                AppRoutes.push(context, ScaffoldExampleScreen());
              },
            ),
            Divider(),
            ListTile(
              title: Text(Strings.example2),
              onTap: () {
                AppRoutes.push(context, CustomOfflineWidgetScreen());
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
```

<img src="https://cdn-images-1.medium.com/max/600/1*0ClOpA0bDy57h8ib9XiqQg.gif" alt="Image 1" style="width: 280px; object-fit: cover; aspect-ratio: 9/16;">


Also, you can customize the offlineWidget . Let's see few examples.


## Custom Decoration

```dart
....
body: ConnectivityWidgetWrapper(
  decoration: BoxDecoration(
    color: Colors.purple,
    gradient: new LinearGradient(
      colors: [Colors.red, Colors.cyan],
    ),
  ),
  child: ListView(
....
```

<img src="https://cdn-images-1.medium.com/max/600/1*qUAaseD03Jrk7I91LDv-sQ.png" alt="Image 2" style="width: 280px; object-fit: cover; aspect-ratio: 9/16;">


## Custom Height and Message

```dart
...
body: ConnectivityWidgetWrapper(
  decoration: BoxDecoration(
    color: Colors.purple,
    gradient: new LinearGradient(
      colors: [Colors.red, Colors.cyan],
    ),
  ),
  height: 150.0,
  message: "You are Offline!",
  messageStyle: TextStyle(
    color: Colors.white,
    fontSize: 40.0,
  ),
  child: ListView(
...
```

<img src="https://cdn-images-1.medium.com/max/600/1*OeVKSyfV2X9VhupXRdwb2g.png" alt="Image 3" style="width: 280px; object-fit: cover; aspect-ratio: 9/16;">

## Custom Alignment and Disable User Interaction
 

```dart
...
body: ConnectivityWidgetWrapper(
  alignment: Alignment.topCenter,
  disableInteraction: true,
  child: ListView(
...
```

<img src="https://cdn-images-1.medium.com/max/600/1*wHJXb7XqHizgEvZ-RjhsDA.gif" alt="Image 4" style="width: 280px; object-fit: cover; aspect-ratio: 9/16;">


## Provide your own Custom Offline Widget

```dart
...
body: ConnectivityWidgetWrapper(
  disableInteraction: true,
  offlineWidget: OfflineWidget(),
  child: ListView.builder(
....
```

<img src="https://cdn-images-1.medium.com/max/600/1*95pBwxafvlsDvcYIs9krJQ.gif" alt="Image 5" style="width: 280px; object-fit: cover; aspect-ratio: 9/16;">

## Convert Any widget to network-aware widget

Wrap the widget `RaisedButton` which you want to be network-aware with `ConnectivityWidgetWrapper` and set `stacked: false`.
Provide an `offlineWidget` to replace the current widget when the device is offline.

```dart
class NetworkAwareWidgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.example3),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: 'Email'),
          ),
          P5(),
          TextField(
            decoration: InputDecoration(labelText: 'Password'),
          ),
          P5(),
          ConnectivityWidgetWrapper(
            stacked: false,
            offlineWidget: RaisedButton(
              onPressed: null,
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Connecting",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    P5(),
                    CupertinoActivityIndicator(radius: 8.0),
                  ],
                ),
              ),
            ),
            child: RaisedButton(
              onPressed: () {},
              child: Text(
                "Sign In",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
```

<img src="https://cdn-images-1.medium.com/max/600/1*Biyy0EnWf8yVeA40iJcKGQ.gif" alt="Image 6" style="width: 280px; object-fit: cover; aspect-ratio: 9/16;">

<br></br>

> Note that you should not be using the current network status for deciding
whether you can reliably make a network connection. Always guard your app code
against timeouts and errors that might come from the network layer.

## Contributing

We welcome contributions in various forms:

- Proposing new features or enhancements.
- Reporting and fixing bugs.
- Engaging in discussions to help make decisions.
- Improving documentation, as it is essential.
- Sending Pull Requests is greatly appreciated!

A big thank you to all our contributors! 🙌

<br></br>
<div align="center">
  <a href="https://github.com/nonstopio/flutter_forge/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=nonstopio/flutter_forge"  alt="contributors"/>
  </a>
</div>
