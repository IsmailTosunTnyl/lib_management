import 'package:flutter/material.dart';
// import firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
// import cloud_firestore plugin
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lib_management/widgets/MainDrawer.dart';
import 'bookPage.dart';
import 'package:lib_management/model/desk.dart';
import 'package:lib_management/widgets/DeskPage.dart';
import 'package:lib_management/widgets/BookAIPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // This widget is the root of your application.

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        
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
            return const MainsPageContent(title: 'Lib Management Plus');
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MainsPageContent extends StatefulWidget {
  const MainsPageContent({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainsPageContent> createState() => _MainsPageContentState();
}

class _MainsPageContentState extends State<MainsPageContent> {
  int _counter = 0;
  String _page = "BookPage";
  FirebaseAuth auth = FirebaseAuth.instance;

  final Stream<QuerySnapshot> _testStream =
      FirebaseFirestore.instance.collection('Test').snapshots();

  final Stream<QuerySnapshot> _booksStream =
      FirebaseFirestore.instance.collection('Books').snapshots();

  void _incrementCounter() async {
    var userref = FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser!.uid);

    var user = await userref.get();
    var books = user.data()!['booksinuse'];
    books.add(FirebaseFirestore.instance.collection('Books').doc("1984"));
    userref.update({'booksinuse': books});
    books.forEach((element) async {
      var x = await element.get();
      print(x.data());
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Object? data = documentSnapshot.data();
      } else {
        print('Document does not exist on the database');
      }
    });
    setState(() {
      /*
      FirebaseFirestore.instance.collection('Books').doc("1984").set({
        "author": "George Orwell",
        "available": 3,
        "image":
            "https://i.dr.com.tr/cache/500x400-0/originals/0000000064038-1.jpg",
        "name": "1984",
        "publisher": "Can Yayınları"
      });*/
      _counter++;
    });
  }

  void PageChange(String page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(54, 33, 149, 243),
        title: Text(widget.title),
      ),
      drawer: MainDrawer(PageChange: PageChange),
      body: _page == "BookPage"
          ? BookPage(
              context: context,
            )
          : _page == "DeskPage"
              ? DeskPage(
                  context: context,
                )
              : BookAIPage(
                  context: context,
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.replay),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
