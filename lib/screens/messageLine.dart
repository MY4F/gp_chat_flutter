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

class MessageLine extends StatelessWidget {
  const MessageLine({this.audioNumber,this.type,this.text,this.sender,Key?key}) : super(key: key);

  final String? text;
  final String? sender;
  final String? audioNumber;
  final int? type;

  Future<String?> getExternalStoragePath() async {
    Directory? directory;
    try {
      directory = await getExternalStorageDirectory();
    } catch (e) {
      print('Failed to get external storage directory: $e');
    }
    String? path = directory?.path;
    return path;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft:  Radius.circular(30),
                bottomRight:  Radius.circular(30)
            ),
            color: Colors.blue[800],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: type==1? Text(
                '${text}',
                style: TextStyle(fontSize: 15,color: Colors.white),
              ):IconButton(onPressed: () async{
                print(audioNumber);
                String? externalStoragePath = await getExternalStoragePath();
                final player = AudioPlayer();
                await player.play(DeviceFileSource('$externalStoragePath/audio$audioNumber.wav'));
              },
                  icon: Icon(Icons.start)),
            ),
          ),
        ],
      ),
    );
  }
}
