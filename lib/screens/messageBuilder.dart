import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gp_chat_flutter/screens/messageLine.dart';
final _firestore = FirebaseFirestore.instance;

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').orderBy('time').snapshots(),
        builder: (context,snapshot) {
          List<MessageLine>  messageWidgets =[];
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          }
          final messages  = snapshot.data!.docs.reversed;
          for(var message in messages){
            if(message.get('text').indexOf('!=@audio-') == -1) {
              final messageText = message.get('text');
              final messageSender = message.get('sender');
              final messageWidget = MessageLine(
                  audioNumber: '0',type:1,text: messageText, sender: messageSender);
              messageWidgets.add(messageWidget);
            }
            else{
              var no = message.get('text').split('-');
              final messageSender = message.get('sender');
              final messageWidget = MessageLine(
                  audioNumber: no[1], type:2,text: 'Audio Message', sender: messageSender);
              messageWidgets.add(messageWidget);
            }
          }

          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              children: messageWidgets,
            ),
          );
        }
    );
  }
}
