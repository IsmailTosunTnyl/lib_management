import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lib_management/model/book.dart';
import 'package:lib_management/widgets/components/my_button.dart';
import 'package:lib_management/widgets/components/my_textfield.dart';
import 'package:lib_management/model/secret.dart';

// create empty statful widget

class BookAIPage extends StatefulWidget {
  final BuildContext context;
  const BookAIPage({Key? key, required this.context}) : super(key: key);

  @override
  _BookAIPageState createState() {
    return _BookAIPageState();
  }
}

class _BookAIPageState extends State<BookAIPage> {
  final inputcontroller = TextEditingController();
  var isThinking = false;
  List<Widget> widgetList = [];

  var booksCollection = FirebaseFirestore.instance.collection('Books');

  void _translateEngToThai(String userinput) async {
    //FocusScope.of(context).requestFocus(FocusNode());
    widgetList = [];
    setState(() {
      widgetList = [];
      isThinking = true;
      widgetList.clear();
    });
    print("*******************************");
    var OPENAI_API_KEY = Keys.api_key;
    userinput +=
        " \n sırası. kitap ismi - yazar\nsırası. kitap ismi - yazar bu formatta yaz ve sadece kitap isimlerini yaz ";
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        "Authorization": 'Bearer ${OPENAI_API_KEY} '
      },
      body: jsonEncode(<String, dynamic>{
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": userinput}
        ]
      }),
    );

    if (response.statusCode == 200) {
      String books = jsonDecode(utf8.decode(response.bodyBytes))["choices"][0]
              ["message"]["content"]
          .toString();

      //books = "1. 1984 - George Orwell\n2. Cesur Yeni Dünya - Aldous Huxley";
      List<String> bookList = books.split("\n"); // satır satır ayırma işlemi
      List<Map<String, String>> parsedList = [];
      List<String> titleList = [];
      for (String book in bookList) {
        List<String> parsedBook = book.split(" - ");
        parsedList.add({
          "title": parsedBook[0].substring(2).trim(),
          "author": parsedBook[1].trim()
        });
        titleList.add(parsedBook[0].substring(2).trim());
      }

      var query = booksCollection.where("name", whereIn: titleList);
      var matchedBooks = await query.get();
      List<Widget> tempwidgetList = [];
      var machedbooktitles = [];
      matchedBooks.docs.forEach((element) {
        tempwidgetList.add(Container(
          constraints: BoxConstraints(
            minHeight: 200,
            minWidth: 190,
          ),
          child: BookWidget(
            book: Book(
                title: element['name'],
                author: element['author'],
                publisher: element['publisher'],
                booksAvailable: element['available'],
                image: element['image'],
                availableDate: null),
          ),
        ));

        machedbooktitles
            .add(element.data()["name"].toString().toLowerCase().trim());

        parsedList = parsedList
            .where((element2) =>
                element2["title"]!.toLowerCase().trim() !=
                element.data()["name"].toString().toLowerCase().trim())
            .toList();
      });
      if (tempwidgetList.isNotEmpty) {
        widgetList.add(const Text(
          "Available Books",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ));
      } else {
        widgetList.add(const Text(
          "No Available Books In Library",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
        ));
      }
      widgetList.add(const SizedBox(
        height: 5,
      ));

      widgetList.add(
        // hozirontally scroable listview
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tempwidgetList,
          ),
        ),
      );

      parsedList.forEach((element) {
        widgetList.add(Card(
          elevation: 7,
          shadowColor: Colors.red,
          child: ListTile(
            leading: Icon(Icons.book),
            title: Text(element["title"]!),
            subtitle: Text(element["author"]!),
          ),
        ));
      });

      setState(() {
        isThinking = false;
        this.widgetList = widgetList;
      });
      FocusScope.of(context).requestFocus(FocusNode());
    } else {
      print(response.body);
      throw Exception('Failed to create album.');
    }
    setState(() {
      isThinking = false;
      this.widgetList = widgetList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: MediaQuery.of(context).size.width < 450
          ? Center(
              child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/Images/bookLogin.png',
                        scale: 1.5,
                        width: double.infinity,
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 80,
                        child: MyTextField(
                          controller: inputcontroller,
                          hintText: "Describe what do you want to read",
                          obscureText: false,
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 20,
                        child: isThinking
                            ? CircularProgressIndicator()
                            : OutlinedButton(
                                style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(10),
                                    shadowColor: MaterialStateColor.resolveWith(
                                        (states) =>
                                            Color.fromARGB(81, 33, 149, 243))),
                                onPressed: () {
                                  _translateEngToThai(inputcontroller.text);
                                },
                                child: const Text("Search"),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: widgetList.isNotEmpty
                        ? ListView(
                            children: widgetList,
                          )
                        : Image.asset(
                            'assets/Images/book.png',
                            scale: 1.5,
                            width: double.infinity,
                          ),
                  )
                ],
              ),
            ))
          : Row(
            children: [
                Stack(
                    children: [
                      Image.asset(
                        'assets/Images/bookLogin.png',
                        scale: 1.5,
                        width: MediaQuery.of(context).size.width * 0.4,
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 80,
                        child: MyTextField(
                          controller: inputcontroller,
                          hintText: "Describe what do you want to read",
                          obscureText: false,
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 20,
                        child: isThinking
                            ? CircularProgressIndicator()
                            : OutlinedButton(
                                style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(10),
                                    shadowColor: MaterialStateColor.resolveWith(
                                        (states) =>
                                            Color.fromARGB(81, 33, 149, 243))),
                                onPressed: () {
                                  _translateEngToThai(inputcontroller.text);
                                },
                                child: const Text("Search"),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                   Container(
                    width: 1000,
                    height: 400,
                    constraints: BoxConstraints(
                     maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: widgetList.isNotEmpty
                        ? ListView(
                            children: widgetList,
                          )
                        : Image.asset(
                            'assets/Images/book.png',
                            scale: 1.5,
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                  )

            ],
          )
    );
  }
}
//test@test.com
