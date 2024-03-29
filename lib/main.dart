import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
// import cloud_firestore plugin
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lib_management/widgets/MainPage.dart';
import 'firebase_options.dart';
import 'package:lib_management/model/book.dart';
import 'package:lib_management/widgets/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        'Got a message whilst in the foreground!*******************************************************');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const Center(
                child: Text('Something went wrong Check Connection'));
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return const MyHomePage(title: 'Flutter Demo Home Page');
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  //flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 --web-renderer html

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        child: Text("This is Alpha Version "),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginBodyScreen())),
      )),
    );
  }
}
//cd android && ./gradlew clean && cd ..