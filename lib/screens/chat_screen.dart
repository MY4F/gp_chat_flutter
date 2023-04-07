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

final _firestore = FirebaseFirestore.instance;
final chatList = [];
Future<int> getAudioNumber() async{
  print('inside');
  final CollectionReference audioCollection = _firestore.collection('audio');
  final QuerySnapshot querySnapshot = await audioCollection.get();
  final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
  var co;
  for (final document in documents) {
    print('here is the document');
    co = document.get('audioNumber');
  }
  return co;
}

Future<int> getAudioValueFromFirestore() async {
  final DocumentSnapshot doc = await _firestore.collection('audio').doc('1ReDpoKvHvveGdP1cTu8').get();
  final int audioValue = doc.get('audioNumber') as int;
  return audioValue;
}

class ChatScreen extends StatefulWidget {
  static const String screenRoute = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late User signedInUser;
  String? messageText;
  late Future<int> counter;



  @override
  void initState() {
    initRecorder();
    requestPermission();
    super.initState();
    getCurrentUser();
  }

  //region
  void requestPermission() async {
    final PermissionStatus permissionStatus = await Permission.manageExternalStorage.request();
    if (permissionStatus != PermissionStatus.granted) {
      throw Exception('Permission denied for storage');
    }
  }
  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  final recorder = FlutterSoundRecorder();

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }
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

  Future startRecord() async {
    String? externalStoragePath = await getExternalStoragePath();
    if (externalStoragePath == null) {
      throw Exception('External storage path not found');
    }
    final int audioValue = await getAudioValueFromFirestore();
    String co = audioValue.toString();
    String path = '$externalStoragePath/audio$co.wav';
    print('Start Record: $path');
    await recorder.startRecorder(toFile: path);
  }

  Future stopRecorder() async {
    final filePath = await recorder.stopRecorder();
    final File file = File(filePath!);
    print('Recorded file path: $filePath');

    String? externalStoragePath = await getExternalStoragePath();
    if (externalStoragePath == null) {
      throw Exception('External storage path not found');
    }
    final int audioValue = await getAudioValueFromFirestore();
    String co = audioValue.toString();
    String destinationPath = '$externalStoragePath/audio$co.wav';
    //print(' here : dest: $destinationPath');
    //print(file);

    /*final Reference storageRef = FirebaseStorage.instance.ref().child('audio');
    final File audioFile = File(destinationPath);
    //print(audioFile);
    final TaskSnapshot taskSnapshot = await storageRef.child('audio$counter.wav').putFile(audioFile);
*/
    print('here is the next audio number  $co');
    _firestore.collection('messages').add({
      'text':'!=@audio-$co',
      'sender':signedInUser.email,
      'time':FieldValue.serverTimestamp(),
      'type':2
    });
    int val = int.parse(co);
    val++;
    final DocumentReference documentReference = _firestore.collection('audio').doc('1ReDpoKvHvveGdP1cTu8');
    await documentReference.update({
      'audioNumber': val,
    });
  }
  //endregion

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


   bool isPressed =false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[900],
        title: Row(
          children: [
            Image.asset('images/logo.png', height: 25),
            SizedBox(width: 10),
            Text('MessageMe'),
            SizedBox(width: 135),
            IconButton(
                onPressed: (){
                  Navigator.pushNamed(context, Search_Screen.screenRoute, arguments: {
                   'List':chatList
                  });
                  //print(chatList);
                  //print(co);
                },
                icon: Icon(Icons.search)
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStreamBuilder(),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;

                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () async {
                        if (recorder.isRecording) {
                          await stopRecorder();
                          setState(() {});
                        } else {
                          await startRecord();
                          setState(() {});
                        }
                      },
                      child: Icon(
                          recorder.isRecording ? Icons.stop : Icons.mic
                      )
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'type':1,
                        'text':messageText,
                        'sender':signedInUser.email,
                        'time':FieldValue.serverTimestamp(),
                        
                      });
                      print('${messageText}   ${signedInUser.email}');
                    },
                    child: Text(
                      'send',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  )],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    chatList.add(text);
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
