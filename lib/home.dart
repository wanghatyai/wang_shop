import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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

import 'package:firebase_messaging/firebase_messaging.dart';



class Home extends StatefulWidget {


  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  BlocCountOrder blocCountOrder;

  final formatter = new NumberFormat("#,##0.00");

  List user = [];
  String name;
  String value;
  String userCode;
  var overdueStatus = 0;
  var overdueValue = 0.0;
  var overdueNewDate;
  String overdueBillCode;
  Map<String, dynamic> overdueBillAllDetail = {};

  DateFormat dateFormat;
  //DateFormat timeFormat;

  var countOrderAll;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  getUser() async {
    var res = await databaseHelper.getList();
    //print(res);

    setState(() {
      user = res;
      name = user[0]['name'];
      userCode = user[0]['code'];
    });

  }

  getOverdue() async {
    final res = await http.get('https://wangpharma.com/API/overduePopup.php?act=Overdue&userCode=$userCode');
    if(res.statusCode == 200){

      setState(() {

        var jsonData = json.decode(res.body);

        if(jsonData.isNotEmpty){
          overdueBillAllDetail = jsonData[0];

          /*jsonData.forEach((overDueGet) {
          overdueValue = double.parse(overDueGet['CBS_Price_Bill']);
          //overdueBillAllDetail[0]['overdueBillCode'] = overDueGet['CBS_Number'];
        });*/

          overdueStatus = jsonData.length;

          print(overdueBillAllDetail);

          print('overdue--${jsonData.length}');
          var newDateTimeObj2 = DateFormat('yyyy-MM-dd').parse(overdueBillAllDetail['CBS_Date_Receive']);
          //dateFormate = DateFormat("dd-MM-yyyy").format(DateTime.parse("2019-09-30"));
          dateFormat.format(newDateTimeObj2);
          print(DateFormat("dd-MM-yyyy").format(DateFormat('yyyy-MM-dd').parse(overdueBillAllDetail['CBS_Date_Receive'])));
          //print(DateFormat('yyyy-MM-dd').parse(overdueBillAllDetail['CBS_Date_Receive']));
          //var newDateTimeObj2 = new DateFormat("dd/MM/yyyy HH:mm:ss").parse("10/02/2000 15:13:09")
        }

      });
    }

    if(overdueStatus > 0) {
    this.showDialogOverdue();
    }

    //return overdueBillAllDetail;

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
    setupNotif();
    initializeDateFormatting();

    dateFormat = new DateFormat.yMMMMd('th');
    //timeFormat = new DateFormat.Hms('cs');
    getOverdue();

      /*Future.delayed(Duration.zero, () {
        //if(overdueStatus > 0) {
          this.showDialogOverdue();
        //}
      });*/

  }

  showDialogOverdue() {
    // flutter defined function
    showDialog(
      //barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("แจ้งเตือน"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('$userCode'),
              Text('ร้าน : $name', style: TextStyle(fontSize: 18),),
              Divider(color: Colors.black,),
              Text('เลขที่ใบวางบิล'),
              Text('   ${overdueBillAllDetail['CBS_Number']}', style: TextStyle(fontSize: 20),),
              Divider(color: Colors.black,),
              Container(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('ครบกำหนดชำระ', style: TextStyle(color: Colors.white),),
                    Text(DateFormat("dd/MM/yyyy").format(DateFormat('yyyy-MM-dd').parse(overdueBillAllDetail['CBS_Date_Receive'])), style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('ยอดค้างชำระ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                    Text(formatter.format(double.parse(overdueBillAllDetail['CBS_Price_Balance'])), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
              ),
              Text('ขออภัยในความไม่สะดวก:', style: TextStyle(fontWeight: FontWeight.bold),),
              Text('    หากท่านได้มีการชำระยอดใบวางบิลดังกล่าวเป็นที่เรียบร้อยแล้ว ต้องขออภัยมา ณ ที่นี้ด้วย หากมีข้อสงสัย หรือสอบถามข้อมูลเพิ่มเติม สามารถติดต่อสอบถามได้ที่ 088-788-6967  K.กำธร ( เจ้าหน้าที่ฝ่ายบัญชี )'),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              color: Colors.green,
              child: Text("ตกลง",style: TextStyle(color: Colors.white, fontSize: 18),),
              onPressed: () {
                Navigator.pop(context);
                //Navigator.popUntil(context, ModalRoute.withName('/Home'));
              },
            ),
          ],
        );
      },
    );
  }

  setupNotif() async {
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
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

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



