import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wang_shop/product_pro.dart';
import 'package:wang_shop/product_hot.dart';
import 'package:wang_shop/history.dart';
import 'package:wang_shop/database_helper.dart';


class Home extends StatefulWidget {

  //String username;

  //Home({Key key, this.username}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List user = [];
  String name;
  String value;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  getUser() async {
    var res = await databaseHelper.getList();
    print(res);

    setState(() {
      user = res;
      name = user[0]['name'];
    });

  }

  /*_readData(key,val) async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    val = prefer.getString(key);
    //print(val);
  }*/

  /*_readData(key,val) async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    val = prefer.getString(key);
    print(val);
  }*/

  @override
  void initState(){
    super.initState();
    //_readData('name',username);
    //print(_readData('name',username));
    //print(username);
    //_readData('name');
    getUser();

  }

  /*Widget appBar = AppBar(
    backgroundColor: Colors.green,
    title: Text("Home-$username"),
    actions: <Widget>[
      IconButton(icon: Icon(Icons.account_circle), onPressed: (){})
    ],
  );*/

  int currentIndex = 0;
  List pages = [ProductProPage(), ProductHotPage(), History()];


  @override
  Widget build(BuildContext context) {

    Widget bottomNavBar = BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index){
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.assistant_photo), title: Text('โปร')),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), title: Text('ขายดี')),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), title: Text('ประวัติ')),
        ]
    );

    //username = _readData('name');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("${name}"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.account_circle), onPressed: (){})
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: bottomNavBar,
    );
  }



}



