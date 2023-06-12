import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lib_management/firebase_options.dart';
import 'package:lib_management/main.dart';
import 'package:lib_management/widgets/login.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() async {
  testWidgets('MyHomePage displays Alpha Version button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyHomePage(title: 'Test Title'),
      ),
    );

    // Verify that the Alpha Version button is displayed
    expect(find.text('This is Alpha Version '), findsOneWidget);

    // Tap the Alpha Version button
    await tester.tap(find.text('This is Alpha Version '));
    await tester.pumpAndSettle();

    // Verify that the LoginBodyScreen is pushed to the navigator
    expect(find.byType(LoginBodyScreen), findsOneWidget);
  });

  testWidgets('LoginBodyScreen displays login form',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginBodyScreen(),
      ),
    );

    // Verify that the email field is displayed
    expect(find.byKey(const Key('email')), findsOneWidget);

    // Verify that the password field is displayed
    expect(find.byKey(const Key('password')), findsOneWidget);

    // Verify that the submit button is displayed
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('Firestore Book Add', (WidgetTester tester) async {
    final instance = FakeFirebaseFirestore();

    var data = await instance.collection('Books').get();
    instance.collection('Books').add({
      'title': 'title',
      'author': 'author',
      'publisher': 'publisher',
      'booksAvailable': 5,
      'image': 'https://example.com/book-image.jpg',
      'availableDate': DateTime.now(),
    });
    print(data.docs.length);
    data = await instance.collection('Books').get();
    print(data.docs.length);
  });

  testWidgets('firestore book reservatinon add', (WidgetTester tester) async {
    final instance = FakeFirebaseFirestore();

    instance.collection('Books').add({
      'title': 'title',
      'author': 'author',
      'publisher': 'publisher',
      'booksAvailable': 5,
      'image': 'https://example.com/book-image.jpg',
      'availableDate': DateTime.now(),
    });
    var data = await instance.collection('Books').get();
    print(data.docs[0].data());
    instance.collection('BookReservation').add({
      'book': data.docs[0].data(),
      'reservationDate': DateTime.now(),
      'returnDate': DateTime.now(),
    });
    var data2 = await instance.collection('BookReservation').get();
    expect(data2.docs.length, 1);
  });

  testWidgets('Firestore Book Reservatinon Delete',
      (WidgetTester tester) async {
    final instance = FakeFirebaseFirestore();

    instance.collection('Books').add({
      'title': 'title',
      'author': 'author',
      'publisher': 'publisher',
      'booksAvailable': 5,
      'image': 'https://example.com/book-image.jpg',
      'availableDate': DateTime.now(),
    });
    var data = await instance.collection('Books').get();
    print(data.docs[0].data());
    instance.collection('BookReservation').add({
      'book': data.docs[0].data(),
      'reservationDate': DateTime.now(),
      'returnDate': DateTime.now(),
    });
    var data2 = await instance.collection('BookReservation').get();
    // delete reservation
    await instance.collection('BookReservation').doc(data2.docs[0].id).delete();
    data2 = await instance.collection('BookReservation').get();
    expect(data2.docs.length, 0);
  });

    testWidgets('Firestore Desk Reservatinon add',
      (WidgetTester tester) async {
    final instance = FakeFirebaseFirestore();

    instance.collection('desk').add({
      'deskId': 1,
      'deskAvailable': true,
    });
    var data = await instance.collection('desk').get();
    expect(data.docs.length, 1);
    instance.collection('DeskReservation').add({
      'desk': data.docs[0].data(),
      'reservationDate': DateTime.now(),
      'endDate': DateTime.now(),
    });
    var data2 = await instance.collection('DeskReservation').get();

    expect(data2.docs.length, 1);
  });


  testWidgets('Firestore Desk Reservatinon Delete',
      (WidgetTester tester) async {
    final instance = FakeFirebaseFirestore();

    instance.collection('desk').add({
      'deskId': 1,
      'deskAvailable': true,
    });
    var data = await instance.collection('desk').get();
    expect(data.docs.length, 1);
    instance.collection('DeskReservation').add({
      'desk': data.docs[0].data(),
      'reservationDate': DateTime.now(),
      'endDate': DateTime.now(),
    });
    var data2 = await instance.collection('DeskReservation').get();
    // delete reservation
    await instance.collection('DeskReservation').doc(data2.docs[0].id).delete();
    data2 = await instance.collection('DeskReservation').get();
    expect(data2.docs.length, 0);
  });
}
