import 'package:flutter/material.dart';
import 'package:gp_chat_flutter/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
late List<String> genderList=[];
late List<int> indicesList=[];
Map data = {};
class _Search_ScreenState extends State<Search_Screen> {
  TextEditingController? _textController = TextEditingController();
  List<String> dataListOnSearch=[];





  @override
  void initState() {
    print("created");
  }
  clear(){

    setState(() {
      _textController!.text='';
    });
  }
  @override
  String? choosenRadioButton="All";

  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;

    setState(() {
      email = data['email'];
    });
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
        title: Container(
          decoration: BoxDecoration(color: Colors.grey[300],
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                dataListOnSearch.clear();
                indicesList.clear();
                if(choosenRadioButton=="All") {
                  print("in all");

                  dataListOnSearch =
                      dataList.where((element) => element.contains(value))
                          .toList();
                }
                else if (choosenRadioButton =="Male"){
                  print("in male");
                  for(int i=0;i< dataList.length;i++){
                    if(genderList[i]=="male"){
                      dataListOnSearch.add(dataList[i]);
                      indicesList.add(i);
                    }
                  }
                  print(genderList.length);
                }
                else{
                  print("in female");
                  for(int i=0;i< dataList.length;i++){
                    if(genderList[i]=="female"){
                      dataListOnSearch.add(dataList[i]);
                      indicesList.add(i);
                    }
                  }
                }
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
      body:Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Radio(
                  value: "All",
                  groupValue:choosenRadioButton,
                  onChanged: (value) {
                    setState(() {
                      choosenRadioButton=value as String?;

                    });
                  },
                ),
              ),
              Expanded(child: Text('All',style: TextStyle(fontSize: 13),)),
              Expanded(
                child: Radio(
                  value: 'Male',
                  groupValue: choosenRadioButton,
                  onChanged: (value) {

                    setState(() {
                      choosenRadioButton=value as String?;

                    });


                  },
                ),
              ),
              Expanded(child: Text('Male',style: TextStyle(fontSize: 13),)),
              Expanded(
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
              Expanded(child: Text('Female',style: TextStyle(fontSize: 13),)),
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
                stream: _firestore.collection('users').doc('${_auth.currentUser?.email}').collection('yasser@gmail.com').orderBy('time').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }

                if(dataListOnSearch.isNotEmpty){
                  return ListView.builder(
                      itemCount: _textController!.text.isNotEmpty? dataListOnSearch.length:dataList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ListTile(
                            onTap: (){
                              //print(index);
                              Navigator.pop(context, indicesList[index]);
                            },
                            title:
                            Text(_textController!.text.isNotEmpty? dataListOnSearch[index]:dataList[index], overflow: TextOverflow.visible,
                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                          ),
                        );
                      });
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    dataList.clear();
                    genderList.clear();
                    for(var x in snapshot.data!.docs.reversed) {
                      if(x.get('message').indexOf('!=@audio-') == -1) {
                        dataList.add(x['message']);
                        genderList.add("not audio");
                      }
                      else{
                        var splittedMesssage = x.get('message').split('(-{}-) ');
                        if(splittedMesssage.length>1) {
                          dataList.add(splittedMesssage[1]);
                          genderList.add(x["gender"]);
                          //print(splittedMesssage[1]);
                        }
                      }

                    }
                    print(genderList);
                    return ListTile(
                      onTap: (){
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
