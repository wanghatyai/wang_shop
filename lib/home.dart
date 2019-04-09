import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wang_shop/product_pro.dart';
import 'package:wang_shop/product_hot.dart';
import 'package:wang_shop/product_new.dart';
import 'package:wang_shop/history.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:wang_shop/order.dart';
import 'package:wang_shop/search.dart';
import 'package:wang_shop/search_auto.dart';
import 'package:wang_shop/search_auto_out.dart';


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
    showOverlay();

  }

  showOverlay() async{

    var countOrder = await databaseHelper.countOrder();
    print(countOrder[0]['countOrderAll']);

    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 25,
          right: 30,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.red,
            child: Text("${countOrder[0]['countOrderAll']}",style: TextStyle(color: Colors.white)),
          ),
        )
    );

    overlayState.insert(overlayEntry);
    //await Future.delayed(Duration(seconds: 2));
    //overlayEntry.remove();
  }

  /*Widget appBar = AppBar(
    backgroundColor: Colors.green,
    title: Text("Home-$username"),
    actions: <Widget>[
      IconButton(icon: Icon(Icons.account_circle), onPressed: (){})
    ],
  );*/

  int currentIndex = 0;
  List pages = [ProductProPage(), ProductHotPage(), ProductNewPage(), searchAutoOutPage(), History()];


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
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant_photo, color: Colors.green),
            title: Text('โปร', style: TextStyle(color: Colors.green))
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket, color: Colors.green),
            title: Text('ขายดี', style: TextStyle(color: Colors.green))
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.fiber_new, color: Colors.green),
              title: Text('ใหม่', style: TextStyle(color: Colors.green))
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.green),
            title: Text('ค้นหา', style: TextStyle(color: Colors.green))
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time, color: Colors.green),
            title: Text('ประวัติ', style: TextStyle(color: Colors.green))
          ),
        ]
    );

    //username = _readData('name');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("${name}"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.shopping_cart, size: 30,),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
          })
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: bottomNavBar,
    );
  }



}



