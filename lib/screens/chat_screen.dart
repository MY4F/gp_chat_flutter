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

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
late String email;
late int highlightedIndex=-1;
Future<List<String>> getMessages() async{
  final CollectionReference messagesCollection = _firestore.collection('messages');
  final QuerySnapshot querySnapshot = await messagesCollection.get();
  final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
  //print(documents[0].get('text'));
  late List<String> messages = [];
  for (final document in documents) {
    if(document.get("text") && document.get("text").indexOf('!=@audio-') == -1)
      messages.add(document.get("text").toString());
  }
  return messages;
}

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


    //Server request region
//https://gp-model.onrender.com/upload
//     final url = Uri.parse('https://139f-34-73-10-235.ngrok-free.app/upload');
//   // Create a new multipart request with the POST method
//     final request = http.MultipartRequest('POST', url);
//   // Add the audio file to the request
//     request.files.add(await http.MultipartFile.fromPath('audio', destinationPath));
//   // Send the request
//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();
//
//     final x = json.decode(responseBody);
//     print("here response body");
//     print(x["transcription"]);
//   // Print the response status code
//     print(response.statusCode);
//
//     print('here is the next audio number  $co');
    _firestore.collection('users').doc('${_auth.currentUser?.email}').collection(email).add({
      'message':'!=@audio-$co(-{}-) hello',
      'sender':signedInUser.email,
      'time':FieldValue.serverTimestamp(),
      'type':2,
      'gender':'male'
    });

    _firestore.collection('users').doc(email).collection('${_auth.currentUser?.email}').add({
      'message':'!=@audio-$co(-{}-) hello',
      'sender':signedInUser.email,
      'time':FieldValue.serverTimestamp(),
      'type':2,
      'gender':'male'
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

  Map data = {};
   bool isPressed =false;
  @override
  Widget build(BuildContext context) {

    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;
    print("i am here");
    print(data);
    setState(() {
      email = data['user'];
    });

    

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset('images/logo1.png', height: 25),
            SizedBox(width: 10),
            Text('Voicey Chat', style: TextStyle(color: Colors.black)),
            SizedBox(width: 10),
            IconButton(
                onPressed: () async {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => Search_Screen(),
                  //   ),
                  // ).then((value) {
                  //   // Receive the data here
                  //   setState(() {
                  //     highlightedIndex = value;
                  //     print(value);
                  //   });
                  // });
                  Navigator.pushNamed(context,Search_Screen.screenRoute, arguments: {
                    'email':email
                  }).then((value) {
                         // Receive the data here
                         setState(() {
                         highlightedIndex = value as int;
                          print(value);
                       });
                     });
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
             // MessageStreamBuilder()

            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('users').doc('momoteak6089@gmail.com').collection('yasser@gmail.com').orderBy('time').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                  List<DocumentSnapshot> docs = snapshot.data!.docs;
                  List<MessageLine>  messageWidgets =[];
                  int j = 0;
                  for(var message in docs.reversed){
                    print(message.data());
                    if(message.get('message').indexOf('!=@audio-') == -1) {
                      final messageText = message.get('message');
                      final messageSender = message.get('sender');
                      final messageWidget = MessageLine(highlighted: j == highlightedIndex,
                          audioNumber: '0',type:1,text: messageText, sender: messageSender);
                      messageWidgets.add(messageWidget);
                    }
                    else{
                      var no = message.get('message').split('-');
                      var no2 = no[1].split('(');
                      print(no2[0]);
                      final messageSender = message.get('sender');
                      final messageWidget = MessageLine(highlighted: j == highlightedIndex,
                          audioNumber: no2[0], type:2,text: 'Audio Message', sender: messageSender);
                      messageWidgets.add(messageWidget);
                    }
                    j++;
                  }
                  return ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                   children: messageWidgets,
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black12,
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
                          recorder.isRecording ? Icons.stop : Icons.mic,color: Colors.black,
                      )
                  ),
                  TextButton(
                    onPressed: () async {
                      messageTextController.clear();
                      print(email);
                      await _firestore.collection('users').doc('${_auth.currentUser?.email}').collection(email).add({
                        'type':1,
                        'message':messageText,
                        'sender':signedInUser.email,
                        'time':FieldValue.serverTimestamp(),

                      });
                      await _firestore.collection('users').doc(email).collection('${_auth.currentUser?.email}').add({
                        'type':1,
                        'message':messageText,
                        'sender':signedInUser.email,
                        'time':FieldValue.serverTimestamp(),

                      });
                      print('${messageText}   ${signedInUser.email}');


                    },
                    child: Text(
                      'send',
                      style: TextStyle(
                        color: Colors.black,
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

class MessageLine extends StatefulWidget {
  MessageLine({this.highlighted,this.audioNumber,this.type,this.text,this.sender,Key?key}) : super(key: key);
  final String? text;
  final String? sender;
  final String? audioNumber;
  final int? type;
  bool? highlighted;

  @override
  State<MessageLine> createState() => _MessageLineState();
}



class _MessageLineState extends State<MessageLine> {

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
    Timer(Duration(seconds: 10), () {
      setState(() {
        widget.highlighted = false;
        highlightedIndex=-1;
      });
    });
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: (widget.sender==_auth.currentUser?.email) ?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [(widget.sender==_auth.currentUser?.email)?
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft:  Radius.circular(30),
              bottomRight:  Radius.circular(30)
            ),
            color: ((widget.highlighted==true)? Colors.red:Colors.black),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: widget.type==1? Text(
                '${widget.text}',
                style: TextStyle(fontSize: 15,color: Colors.white),
              ):IconButton(onPressed: () async{
                print(widget.audioNumber);
                String? externalStoragePath = await getExternalStoragePath();
                final player = AudioPlayer();
                await player.play(DeviceFileSource('$externalStoragePath/audio${widget.audioNumber}.wav'));
              },
                  icon: Icon(Icons.start),color: Colors.white,),
            ),
          ):
        Material(
          elevation: 5,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomLeft:  Radius.circular(30),
              bottomRight:  Radius.circular(30)
          ),
          color: ((widget.highlighted==true)? Colors.red:Colors.grey),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
            child: widget.type==1? Text(
              '${widget.text}',
              style: TextStyle(fontSize: 15,color: Colors.white),
            ):IconButton(onPressed: () async{
              print(widget.audioNumber);
              String? externalStoragePath = await getExternalStoragePath();
              final player = AudioPlayer();
              await player.play(DeviceFileSource('$externalStoragePath/audio${widget.audioNumber}.wav'));
            },
              icon: Icon(Icons.start),color: Colors.white,),
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
        stream: _firestore.collection('users').doc('momoteak6089@gmail.com').collection('yasser@gmail.com').orderBy('time').snapshots(),
        builder: (context,snapshot) {
          List<MessageLine>  messageWidgets =[];
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          }
          int i = 0;
          final messages  = snapshot.data!.docs.reversed;
          for(var message in messages){
            print("jere");
            print(message);
            if(message.get('text').indexOf('!=@audio-') == -1) {
              final messageText = message.get('text');
              final messageSender = message.get('sender');
              final messageWidget = MessageLine(highlighted: i == highlightedIndex,
                  audioNumber: '0',type:1,text: messageText, sender: messageSender);
              messageWidgets.add(messageWidget);
            }
            else{
              var no = message.get('text').split('-');
              var no2 = no[1].split('(');
              print(no2[0]);
              final messageSender = message.get('sender');
              final messageWidget = MessageLine(highlighted: i == highlightedIndex,
                 audioNumber: no2[0], type:2,text: 'Audio Message', sender: messageSender);
              messageWidgets.add(messageWidget);
            }
            i++;
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





Future<List<DocumentSnapshot>> getSubCollectionDocuments() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc('momoteak6089@gmail.com')
      .collection('yasser@gmail.com')
      .orderBy('time')
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
  late List<String> msgs  =[];
  late List<String> sender =[];
  @override
  void initState() {
    super.initState();
    getSubCollectionDocuments().then((docs) {
      setState(() {
        documents = docs;
        for(final l in docs){
          msgs.add(l.get('message'));
          sender.add(l.get('sender'));
        }
      });
    });
  }

  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
      List<MessageLine>  messageWidgets =[];
        if(documents == null){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
            ),
          );
        }

        int j = 0;
        for(int i = 0 ;i<msgs.length;i++) {
          if (msgs[i].indexOf('!=@audio-') == -1) {
            final messageText = msgs[i];
            final messageSender = sender[i];
            final messageWidget = MessageLine(
                highlighted: j == highlightedIndex,
                audioNumber: '0',
                type: 1,
                text: messageText,
                sender: messageSender);
            messageWidgets.add(messageWidget);
          }
          else {
            var no = msgs[i].split('-');
            var no2 = no[1].split('(');
            print(no2[0]);
            final messageSender = sender[i];
            final messageWidget = MessageLine(
                highlighted: j == highlightedIndex,
                audioNumber: no2[0],
                type: 2,
                text: 'Audio Message',
                sender: messageSender);
            messageWidgets.add(messageWidget);
          }
        }
        j++;
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            children: messageWidgets,
          ),
        );

        // return ListView(
        //    reverse: true,
        //    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
        //    children: messageWidgets,
        // );
      },
    );
  }
}


