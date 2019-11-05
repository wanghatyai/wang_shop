import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wang_shop/home_new.dart';
import 'package:wang_shop/member.dart';
import 'package:wang_shop/product_pro.dart';
import 'package:wang_shop/product_hot.dart';
import 'package:wang_shop/product_new.dart';
import 'package:wang_shop/product_recom.dart';
import 'package:wang_shop/product_wish.dart';
import 'package:wang_shop/product_category.dart';
import 'package:wang_shop/history.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:wang_shop/order.dart';
import 'package:wang_shop/search.dart';
import 'package:wang_shop/search_auto.dart';
import 'package:wang_shop/search_auto_out.dart';

import 'package:wang_shop/news.dart';


import 'package:wang_shop/order_bill_status.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';



class Home extends StatefulWidget {


  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {

  //FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  BlocCountOrder blocCountOrder;

  List user = [];
  String name;
  String value;

  var countOrderAll;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  getUser() async {
    var res = await databaseHelper.getList();
    print(res);

    setState(() {
      user = res;
      name = user[0]['name'];
    });

  }

  _launchURL() async {
    const urlHelp = "https://www.youtube.com/watch?v=CQni6VdSdTs";
    if (await canLaunch(urlHelp)) {
      await launch(urlHelp);
    } else {
      throw 'Could not launch $urlHelp';
    }
  }

  @override
  void initState(){
    super.initState();
    getUser();
    //setupNotif();
  }

  /*setupNotif() async {
    _firebaseMessaging.getToken().then((token){
      print(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async {
        print(msg);
      },
      onResume: (Map<String, dynamic> msg) async {
        print(msg);
      },
      onLaunch: (Map<String, dynamic> msg) async {
        print(msg);
      },

    );
  }*/

  int currentIndex = 0;
  //List pages = [HomeNewPage(), ProductHotPage(), ProductNewPage(), ProductRecomPage(), MemberPage()];
  List pages = [HomeNewPage(), NewsPage(), ProductWishPage(), MemberPage()];


  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    Widget bottomNavBar = BottomNavigationBar(
        backgroundColor: Colors.white,
        fixedColor: Colors.green,
        unselectedItemColor: Colors.blueGrey,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (int index){
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('หน้าหลัก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            title: Text('ข่าวสาร', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add_check),
            title: Text('เคยสั่ง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.thumb_up),
            title: Text('แนะนำ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),*/
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              title: Text('ลูกค้า', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),
        ]
    );

    //username = _readData('name');

    Widget drawer = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("${name}",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black, offset: Offset(1, 2), blurRadius: 2)
                  ]
              )
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/bannerDrawer.jpg')
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.star, color: Colors.amberAccent, size: 30,),
            title: Text("สินค้าที่เคยสั่ง", style: TextStyle(fontSize: 17)),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductWishPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.category, color: Colors.deepOrange, size: 30,),
            title: Text("หมวดสินค้า", style: TextStyle(fontSize: 17)),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductCategoryPage()),
              );

            },
          ),
          ListTile(
            leading: Icon(Icons.view_list, color: Colors.lightGreen, size: 30,),
            title: Text("สถานะรายการ", style: TextStyle(fontSize: 17)),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderBillStatusPage()),
              );

            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Colors.blue, size: 30,),
            title: Text("คู่มือการใช้งาน", style: TextStyle(fontSize: 17)),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: (){
              _launchURL();
            },
          )
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        //title: Text("${name}"),
        title: Container(
          height: 40,
          color: Colors.green,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                Icons.search,
              ),
              hintText: 'ค้นหา',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => searchAutoOutPage()));
            },
          ),
        ),
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            icon: Stack(
              children: <Widget>[
                Icon(Icons.shopping_cart, size: 40,),
                Positioned(
                  right: 0,
                  child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: StreamBuilder(
                        initialData: blocCountOrder.countOrder,
                        stream: blocCountOrder.counterStream,
                        builder: (BuildContext context, snapshot) => Text(
                        '${snapshot.data}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
            }
          )
        ],
      ),
      //drawer: drawer,
      body: pages[currentIndex],
      bottomNavigationBar: bottomNavBar,
    );
  }



}



