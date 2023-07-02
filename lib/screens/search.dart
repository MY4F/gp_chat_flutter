import 'package:flutter/material.dart';
import 'package:gp_chat_flutter/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gp_chat_flutter/screens/email.dart';

final _firestore = FirebaseFirestore.instance;
late String email;
final _auth = FirebaseAuth.instance;

class Search_Screen extends StatefulWidget {
  const Search_Screen({Key? key}) : super(key: key);
  static const String screenRoute = 'search';
  @override
  State<Search_Screen> createState() => _Search_ScreenState();
}
late List<String> dataList=[];
late List<String> dataListAudio=[];

late List<int> dataListAudioIndices=[];
late List<int> tempAudioIndices=[];

late List<String> genderList=[];
late List<String> tempGenderList=[];

late List<int> indicesList=[];
Map data = {};
class _Search_ScreenState extends State<Search_Screen> {
  TextEditingController? _textController = TextEditingController();
  List<String> temp=[];
  List<String> dataListOnSearch=[];




  @override
  void initState() {
    print("created");
    super.initState();

  }
  clear(){

    setState(() {
      _textController!.text='';

    });
  }
  @override
  String? choosenRadioButton="All";
  bool audio=false;

  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;

    print("here dataa");
    print(data);

    setState(() {
      email = UserEmail.Email!;
    });
    print("mail here:  ");
    print(email);
    print(choosenRadioButton);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context,true),
          ),
          title: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        indicesList.clear();
                        dataListAudioIndices.clear();
                        temp.clear();
                        if(choosenRadioButton=="All") {
                          print("in all");
                          dataListOnSearch.clear();
                          if(audio==false) {
                            for (int i = 0; i < dataList.length; i++) {
                              if(dataList[i].contains(value)) {
                                temp.add(dataList[i]);
                                indicesList.add(i);
                              }
                            }
                          }
                          else if( audio==true){
                            for (int i = 0; i < dataListAudio.length; i++) {
                              if(dataListAudio[i].contains(value)) {
                                temp.add(dataListAudio[i]);
                                dataListAudioIndices.add(tempAudioIndices[i]);
                              }
                            }
                          }
                          dataListOnSearch = temp.where((element) => element.contains(value))
                              .toList();
                          print(genderList.length);
                        }

                        else if (choosenRadioButton =="Male"){
                          print("in male");
                          dataListOnSearch.clear();
                          if(audio==false) {
                            for (int i = 0; i < dataList.length; i++) {
                              if (genderList[i] == "male") {
                                temp.add(dataList[i]);
                                indicesList.add(i);
                              }
                            }
                          }
                          else if( audio==true){
                            for (int i = 0; i < dataListAudio.length; i++) {
                              if (tempGenderList[i] == "male") {
                                temp.add(dataListAudio[i]);
                                dataListAudioIndices.add(tempAudioIndices[i]);
                              }
                            }
                          }
                          dataListOnSearch = temp.where((element) => element.contains(value))
                              .toList();
                          print(genderList.length);
                        }

                        else if(choosenRadioButton =="Female"){
                          print("in female");
                          dataListOnSearch.clear();
                          if(audio==false){
                            for(int i=0;i< dataList.length;i++){
                              if(genderList[i]=="female"){
                                temp.add(dataList[i]);
                                indicesList.add(i);
                              }
                            }
                          }

                          else if(audio==true){
                            for(int i=0;i< dataListAudio.length;i++){
                              if(tempGenderList[i]=="female"){
                                temp.add(dataListAudio[i]);
                                dataListAudioIndices.add(tempAudioIndices[i]);
                              }
                            }
                          }

                          dataListOnSearch = temp.where((element) => element.contains(value))
                              .toList();
                          print(genderList.length);
                        }
                        print(dataListOnSearch);
                        print(dataListAudioIndices);
                        print(indicesList);
                      });
                    },
                    controller: _textController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        contentPadding:EdgeInsets.all(15),
                        hintText: "Type the text....",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: clear,
                        )
                    ),
                  ),
                ),
              ),
              IconButton(onPressed: (){setState(() {
                audio==false? audio=true: audio=false;
              });


              },
                  icon: Icon(Icons.keyboard_voice ,color: audio==false?Colors.black:Colors.blue,))


            ],
          ),

        ),
        body:Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    child: Row(
                      children: [

                        Radio(
                          value: "All",
                          groupValue:choosenRadioButton,
                          onChanged: (value) {
                            setState(() {
                              choosenRadioButton=value as String?;
                            });
                          },
                        ),

                        Text('All',
                          style: TextStyle(fontSize: 13,
                          ),)
                      ],
                    ),
                  ),
                ),
                /* Container( color: Colors.white,
                child: Expanded(child: Text('All',style: TextStyle(fontSize: 13,
                     ),)),
              ),*/
                Expanded(
                  child: Container( color: Colors.blue,
                    child: Row(
                      children: [

                        Radio(
                          value: "Male",
                          groupValue:choosenRadioButton,
                          onChanged: (value) {
                            setState(() {
                              choosenRadioButton=value as String?;
                            });
                          },
                        ),

                        Text('Male',
                          style: TextStyle(fontSize: 13,
                          ),)
                      ],
                    ),
                  ),
                ),

                /* Container( color: Colors.blue,
                child: Expanded(
                  child: Radio(
                    value: 'Male',
                    groupValue: choosenRadioButton,
                    onChanged: (value) {
                      setState(() {
                      */
                /*for(int i=0;i< dataList.length;i++){
                       if(genderList[i]=="male"){
                        temp.add(dataList[i]);
                        indicesList.add(i);
                       }
                      }*/
                /*
                      choosenRadioButton=value as String?;
                      });
                    },
                  ),
                ),
              ),
              Container( color: Colors.blue,
                  child: Expanded(
                      child: Text('Male',style: TextStyle(fontSize: 13),))),*/
                Expanded(
                  child: Container( color: Colors.pink,
                    child: Row(
                      children: [

                        Radio(
                          value: "Female",
                          groupValue:choosenRadioButton,
                          onChanged: (value) {
                            setState(() {
                              choosenRadioButton=value as String?;
                            });
                          },
                        ),

                        Text('Female',
                          style: TextStyle(fontSize: 13,
                          ),)
                      ],
                    ),
                  ),
                ),
                /* Container( color: Colors.pink,
                child: Expanded(
                  child: Radio(
                    value: 'Female',
                    groupValue: choosenRadioButton,
                    onChanged: (value) {
                      setState(() {
                        choosenRadioButton=value as String?;
                      });
                    },
                  ),
                ),
              ),
              Container( color: Colors.pink,
                  child: Expanded(
                      child: Text('Female',style: TextStyle(fontSize: 13),)))*/
              ],
            ),
            _textController!.text.isNotEmpty && dataListOnSearch.isEmpty
                ?Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,size: 100),
                SizedBox(height: 10,),
                Text("No Result found",
                  style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),
                ),
              ],
            ))
                :Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('users').doc('${_auth.currentUser?.email}').collection(email).orderBy('time').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }
                  if(dataListOnSearch.isNotEmpty){
                    if(audio==false){
                      return ListView.builder(
                        //itemCount: choosenRadioButton=="All"?dataList.length:dataListOnSearch.length,
                          itemCount: _textController!.text.isNotEmpty? dataListOnSearch.length:dataList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),

                              ),
                              shadowColor:Colors.grey, elevation: 5,
                              // color: genderList[index]=="not audio"? Colors.white: Colors.grey[300],
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                onTap: (){
                                  //print(index);
                                  Navigator.pop(context,indicesList[index]);
                                },
                                /*leading: CircleAvatar(radius: 12,backgroundColor: Colors.black,
                                child:Text(genderList[index]=="not audio"? "T": "A") ),*/
                                title:
                                Text(
                                  _textController!.text.isNotEmpty? dataListOnSearch[index]:dataList[index]
                                  /*choosenRadioButton=="All"?dataList[index]:dataListOnSearch[index]*/
                                  , overflow: TextOverflow.visible,
                                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),



                              ),
                            );
                          });
                    }
                    else if (audio==true){
                      return ListView.builder(
                        //itemCount: choosenRadioButton=="All"?dataList.length:dataListOnSearch.length,
                          itemCount: _textController!.text.isNotEmpty? dataListOnSearch.length:dataListAudio.length,
                          itemBuilder: (context, index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),

                              ),
                              shadowColor:Colors.grey, elevation: 5,
                              // color: genderList[index]=="not audio"? Colors.white: Colors.grey[300],
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                onTap: (){
                                  //print(index);
                                  Navigator.pop(context, dataListAudioIndices[index]);
                                },
                                /*leading: CircleAvatar(radius: 12,backgroundColor: Colors.black,
                                child:Text(genderList[index]=="not audio"? "T": "A") ),*/
                                title:
                                Text(
                                  _textController!.text.isNotEmpty? dataListOnSearch[index]:dataListAudio[index]
                                  /*choosenRadioButton=="All"?dataList[index]:dataListOnSearch[index]*/
                                  , overflow: TextOverflow.visible,
                                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),



                              ),
                            );
                          });
                    }

                  }
                  return ListView.builder(
                    itemCount: audio==false?snapshot.data!.docs.length:dataListAudio.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      dataList.clear();
                      dataListAudio.clear();
                      genderList.clear();
                      int j =0;
                      for(var x in snapshot.data!.docs.reversed) {
                        if(x.get('message').indexOf('!=@audio-') == -1) {
                          dataList.add(x['message']);
                          genderList.add("not audio");
                        }
                        else{
                          var splittedMesssage = x.get('message').split('(-{}-) ');
                          if(splittedMesssage.length>1) {
                            dataList.add(splittedMesssage[1]);
                            dataListAudio.add(splittedMesssage[1]);
                            tempAudioIndices.add(j);
                            tempGenderList.add(x["gender"]);

                            genderList.add(x["gender"]);
                            //print(splittedMesssage[1]);
                          }
                        }
                        j++;
                      }
                      print(genderList);
                      /*if (choosenRadioButton =="All") {
                      return ListTile(
                        onTap: () {
                          //print(index);
                          Navigator.pop(context, index);
                        },
                        title: Text(
                          dataList[index],
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      );

                    }
                    else if (choosenRadioButton =="Male"){

                      dataListOnSearch.clear();
                      temp.clear();
                      for(int i=0;i< dataList.length;i++){
                        if(genderList[i]=="male"){
                          temp.add(dataList[i]);
                          indicesList.add(i);
                        }
                      }
                      return ListTile(
                        onTap: () {
                          //print(index);
                          Navigator.pop(context, index);
                        },
                        title: Text(
                          temp[index],
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      );
                    }*/
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),

                        ),
                        shadowColor:Colors.grey, elevation: 5,

                        child: ListTile( contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          onTap: () {
                            print(index);
                            print("dsfsdfsdfsdffsd");
                            Navigator.pop(context, index);
                          },

                          //Text(genderList[index]=="not audio"? "T": "A"),
                          title: audio==false?Text(
                            dataList[index],
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ):Text(dataListAudio[index],
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      );

                    },
                  );
                },
              ),
            )
          ],
        )
    );
  }
}
