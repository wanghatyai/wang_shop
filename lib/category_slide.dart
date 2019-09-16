import 'package:flutter/material.dart';

class CategorySlidePage extends StatefulWidget {
  @override
  _CategorySlidePageState createState() => _CategorySlidePageState();
}

class _CategorySlidePageState extends State<CategorySlidePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          InkWell(
            onTap: (){
              print('โปร');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Column(
                children: <Widget>[
                  Icon(Icons.assistant_photo, color: Colors.green, size: 40),
                  Text('โปร', style: TextStyle(fontSize: 16))
                ],
              ),
            )
          ),
          InkWell(
              onTap: (){
                print('ขายดี');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.monetization_on, color: Colors.amber, size: 40),
                    Text('ขายดี', style: TextStyle(fontSize: 16))
                  ],
                ),
              )
          ),
          InkWell(
              onTap: (){
                print('ใหม่');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.fiber_new, color: Colors.red, size: 40),
                    Text('ใหม่', style: TextStyle(fontSize: 16))
                  ],
                ),
              )
          ),
          InkWell(
              onTap: (){
                print('แนะนำ');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.thumb_up, color: Colors.blue, size: 40),
                    Text('แนะนำ', style: TextStyle(fontSize: 16))
                  ],
                ),
              )
          ),
          InkWell(
              onTap: (){
                print('ของแถม');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.tag_faces, color: Colors.deepPurple, size: 40),
                    Text('ของแถม', style: TextStyle(fontSize: 16))
                  ],
                ),
              )
          ),
          InkWell(
              onTap: (){
                print('หมวดหมู่');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.list, color: Colors.pink, size: 40),
                    Text('หมวดหมู่', style: TextStyle(fontSize: 16))
                  ],
                ),
              )
          ),

        ],
      ),
    );
  }
}
