import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:gp_chat_flutter/screens/search.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:gp_chat_flutter/screens/chat_screen.dart';
import 'package:gp_chat_flutter/screens/email.dart';
final _auth = FirebaseAuth.instance;

final _firestore = FirebaseFirestore.instance;
Map data = {};
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String screenRoute = 'home_screen';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
late int updatedFriendsLength = 0;
class _HomeScreenState extends State<HomeScreen> {
  @override
  late List<String> users;
  final _auth = FirebaseAuth.instance;
  late User signedInUser;
  TextEditingController? _textController = TextEditingController();
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void getUsers( user ) async {
    // this code to get friends and start show them
    // await _firestore.collection('users')
    //     .get()
    //     .then((QuerySnapshot querySnapshot) {
    //   querySnapshot.docs.forEach((doc) async {
    //     print(doc);
    //     if(doc.id == user) {
    //       await FirebaseFirestore.instance
    //           .collection('users')
    //           .doc(user)
    //           .collection("momo@gmail.com")
    //           .get()
    //           .then((value) => {
    //             for(final c in value.docs){
    //               print(c.data())
    //             }
    //           });
    //     }
    //   });
    // });

    // final docRef = _firestore.collection('users').doc('$user');
    // docRef.get().then(
    //       (DocumentSnapshot doc) {
    //     final data = doc.data() as Map<String, dynamic>;
    //     print(data['friends']);
    //   },
    //   onError: (e) => print("Error getting document: $e"),
    // );
    final CollectionReference usersCollection = _firestore.collection('users').doc('${_auth.currentUser?.email}').collection('yasser@gmail.com');
    final QuerySnapshot querySnapshot = await usersCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

  }

  clear(){

    setState(() {
      _textController!.text='';
    });
  }



  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
            icon: Icon(Icons.logout),
          )
        ],
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                },
                controller: _textController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    contentPadding:EdgeInsets.all(15),
                    hintText: "Type the text....",
                ),

              ),
            ),
            IconButton(onPressed: () async{
              getCurrentUser();
              final user = _auth.currentUser;
              getUsers(user?.email);
              UserEmail.Email = _textController?.text.toString();
              print("print email class");
              print(UserEmail.Email);
              // add doc and array for current user
              _firestore.collection('users').doc('${user?.email}').update({
                'friends': FieldValue.arrayUnion([_textController?.text.toString()])
              });
              _firestore.collection('users').doc('${user?.email}').collection('${_textController?.text.toString()}').doc().set({});

              // add doc and array for user's new friend
              _firestore.collection('users').doc('${_textController?.text.toString()}').update({
                'friends': FieldValue.arrayUnion([user?.email])
              });
              _firestore.collection('users').doc('${_textController?.text.toString()}').collection('${user?.email}').doc().set({});

              setState(() {
              });
            },
                icon: Icon(Icons.add)),
          ],
        ),
      ),
      body:UserBuilder(),
    );
  }
}

Future<List<DocumentSnapshot>> getSubCollectionDocuments() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc('momoteak6089@gmail.com')
      .collection('yasser@gmail.com')
      .get();
  return querySnapshot.docs;
}

class TestUsers extends StatefulWidget {
  const TestUsers({Key? key}) : super(key: key);

  @override
  State<TestUsers> createState() => _TestUsersState();
}

class _TestUsersState extends State<TestUsers> {
  @override

  List<DocumentSnapshot> documents = [];
  late List<String> d  =[];
  @override
  void initState() {
    super.initState();
    getSubCollectionDocuments().then((docs) {
      setState(() {
        documents = docs;
        for(final l in docs){
          d.add(l.get('message'));
        }
      });
    });
  }

  Widget build(BuildContext context) {

    print(d);

    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(d[index]),
          subtitle: Text(d[index]),
        );
      },
    );
  }
}



class UserBuilder extends StatelessWidget {
  const UserBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc('${_auth.currentUser?.email}').get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }
        final messages  = snapshot.data?.data() as Map<String, dynamic>?;
        late List<String> users = [];
        if(messages != null) {
          for(final f in messages['friends']){
            users.add(f);
          }
        }

        if(users.length <1)
          {
            return Text('no friends to show');
          }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: TextButton.icon(
                onPressed: () async {
                  UserEmail.Email = users[index];
                  print("print email class");
                  print(UserEmail.Email);
                  Navigator.pushNamed(context, ChatScreen.screenRoute, arguments: {
                    'user': users[index]
                  });
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(100),
                  padding: EdgeInsets.all(16),
                  backgroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey),
                  ),
                  alignment: Alignment.topLeft
                ),
                icon: Image.asset('images/user4.png'),
                label: Text(
                  users[index],
                  style: TextStyle(fontSize: 20,color: Colors.black),
                ),
              ),
            );

          },
        );
      },
    );
  }
}
