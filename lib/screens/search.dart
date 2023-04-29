import 'package:flutter/material.dart';

class Search_Screen extends StatefulWidget {
  const Search_Screen({Key? key}) : super(key: key);
  static const String screenRoute = 'search';
  @override
  State<Search_Screen> createState() => _Search_ScreenState();
}
List<String> dataList=[];
Map data = {};
class _Search_ScreenState extends State<Search_Screen> {
  TextEditingController? _textController = TextEditingController();
  List<String> dataListOnSearch=[];

  clear(){

    setState(() {
      _textController!.text='';
    });
  }
  @override
  Widget build(BuildContext context) {

    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;

    List<dynamic> d=data['List'];
    if(dataList.isEmpty) {
      for (int i = 0; i < (d.length / 3); i++) {
        dataList.add(d[i].toString());
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Container(
          decoration: BoxDecoration(color: Colors.grey[300],
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                dataListOnSearch=
                    dataList.where((element) => element.contains(value)).toList();
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
      body: _textController!.text.isNotEmpty && dataListOnSearch.isEmpty
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
          :ListView.builder(
        itemCount: _textController!.text.isNotEmpty? dataListOnSearch.length:dataList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                Text(_textController!.text.isNotEmpty? dataListOnSearch[index]:dataList[index],
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
              ],
            ),
          );
        },),
    );
  }
}
