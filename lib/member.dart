import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:wang_shop/database_helper.dart';
import 'package:wang_shop/home.dart';
import 'package:wang_shop/member_model.dart';
import 'package:wang_shop/order_bill_status.dart';
import 'package:wang_shop/order_bill_temps_model.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class MemberPage extends StatefulWidget {
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();
  //FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  var userID;
  var userCode;

  //List <OrderBillTemps>orderBillTempsAll = [];

  List <Member>memberAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Member";

  //Timer timerLoopCheck;
  //var orderBillStatusText;

  getUser() async{

    var resUser = await databaseHelper.getList();
    setState(() {
      userID = resUser[0]['idUser'];
    });

    print(userID);

    final res = await http.get('https://wangpharma.com/API/member.php?userID=$userID&act=$act');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => memberAll.add(Member.fromJson(products)));

        print(memberAll);

        return memberAll;

      });


    }else{
      throw Exception('Failed load Json');
    }

  }

  /*getOrderBillTemps() async{

    orderBillTempsAll = [];

    var resUser = await databaseHelper.getList();
    setState(() {
      userCode = resUser[0]['code'];
    });

    print(userCode);

    final res = await http.get('https://wangpharma.com/API/orderBill.php?orderBillCus=$userCode&act=CheckStatusOrderBill');
    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBillTemps) => orderBillTempsAll.add(OrderBillTemps.fromJson(orderBillTemps)));

        print(orderBillTempsAll);

        loopSendOrderBillNotification();

        //return orderBillTempsAll;

      });


    }else{
      throw Exception('Failed load Json');
    }
    print('check');
  }

  loopSendOrderBillNotification() async{

    var checkCodeOrderTemps;
    var checkOrderTemps;

    for(var index = 0; index < orderBillTempsAll.length; index++){

      //Future.delayed(Duration(seconds: 5), () async{
        checkCodeOrderTemps = await databaseHelper.getOrderTempsCheckCode(orderBillTempsAll[index].orderBillCode);

        if(checkCodeOrderTemps.isEmpty){

          Map orderTemps = {
            'code': orderBillTempsAll[index].orderBillCode,
            'status': orderBillTempsAll[index].orderBillSentStatus,
            'cusCode': userCode,
          };

          await databaseHelper.saveOrderTemps(orderTemps);

          setupNotification(index, orderBillTempsAll[index].orderBillCode, orderBillTempsAll[index].orderBillSentStatus);


          print('orderBillSendNew');
        }else{

          checkOrderTemps = await databaseHelper.getOrderTempsCheck(orderBillTempsAll[index].orderBillCode, orderBillTempsAll[index].orderBillSentStatus);

          if(checkOrderTemps.isEmpty){

            Map orderTempsUp = {
              'code': orderBillTempsAll[index].orderBillCode,
              'status': orderBillTempsAll[index].orderBillSentStatus,
            };

            await databaseHelper.updateOrderTemps(orderTempsUp);


            setupNotification(index, orderBillTempsAll[index].orderBillCode, orderBillTempsAll[index].orderBillSentStatus);


            print('orderBillSendUpdate');
          }else{
            print('orderBillStatusSame');
          }

        }
      //});

    }
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    //setupNotificationPlugin();
    //getOrderBillTemps();

    //timerLoopCheck = Timer.periodic(Duration(minutes: 15), (Timer t) => setupNotification());

    //timerLoopCheck = Timer.periodic(Duration(minutes: 15), (Timer t) => getOrderBillTemps());

    //_clearOrderTempsDB();

  }

  /*void setupNotificationPlugin(){
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid = new AndroidInitializationSettings('ic_notification');
  var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
  /*onSelectNotification: onSelectNotification).then((init){
    setupNotification();
  });*/
  onSelectNotification: onSelectNotification);
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text("ระบบแจ้งเตือนสถานะรายการบิล"),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: (){
              Navigator.of(context).pop();
            },
          )
        ],
      )
    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Home()),
    );
  }

  setupNotification(index, orderBillCode, orderBillStatus)async{

    if(orderBillStatus == '1'){
      orderBillStatusText = 'เปิดบิล';
    }else if(orderBillStatus == '2'){
      orderBillStatusText = 'กำลังจัด';
    }else if(orderBillStatus == '3'){
      orderBillStatusText = 'กำลัง QC';
    }else if(orderBillStatus == '4'){
      orderBillStatusText = 'กำลังแพ็ค';
    }else if(orderBillStatus == '5'){
      orderBillStatusText = 'เตรียมส่ง';
    }else if(orderBillStatus == '6'){
      orderBillStatusText = 'ระหว่างขนส่ง';
    }

    print(orderBillStatusText);

    var scheduledNotificationDateTime = new DateTime.now().add(new Duration(seconds: 1));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails('your other channel id', 'your other channel name', 'your other channel description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        index,
        'รายการบิลเลขที่:$orderBillCode',
        'สถานะ:$orderBillStatusText',
        scheduledNotificationDateTime,
        platformChannelSpecifics);

    /*var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'repeating channel id',
        'repeating channel name',
        'repeating description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics,
        iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'รายการบิลเลขที่:$orderBillCode',
        'สถานะ:$orderBillStatusText',
        RepeatInterval.EveryMinute,
        platformChannelSpecifics);*/
  }*/

  @override
  void dispose() {
    //timerLoopCheck?.cancel();
    super.dispose();
  }

  _dropDB() async{
    await databaseHelper.dropTableOrder();
    await databaseHelper.dropTableOrderFree();
    await databaseHelper.dropTableMembers();
    await databaseHelper.dropTableShipAndPay();
    await databaseHelper.removeAllOrderTemps();
  }

  _clearDB() async{
    //SharedPreferences preferences = await SharedPreferences.getInstance();
    //preferences.clear();
    await databaseHelper.removeAll();
    await databaseHelper.removeAllOrderFree();
    await databaseHelper.removeAllMember();
    await databaseHelper.removeAllOrderTemps();
  }

  _clearOrderTempsDB()async{
    await databaseHelper.removeAllOrderTemps();
  }

  void _showDialogExit() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("แจ้งเตือน"),
          content: new Text("ยืนยันออกจากระบบ"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                _clearDB();
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                //Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogDrop() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("แจ้งเตือน"),
          content: new Text("แก้ไขปัญหา App"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                _dropDB();
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                //Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? CircularProgressIndicator()
          : Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.green
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.account_circle, size: 60, color: Colors.white,),
                            Text('${memberAll[0].memberName}', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Text('ที่อยู่ร้าน : ${memberAll[0].memberAddress}', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Text('สถานะรายการ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Icon(Icons.beenhere, size: 40, color: Colors.grey,),
                                Text('ยืนยันรายการ')
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Icon(Icons.check_circle, size: 40, color: Colors.grey,),
                                Text('เตรียมจัดส่ง')
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Icon(Icons.local_shipping, size: 40, color: Colors.grey,),
                                Text('ระหว่างขนส่ง')
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Icon(Icons.add_comment, size: 40, color: Colors.grey,),
                                Text('รับสินค้าแล้ว')
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Text('ข้อมูลลูกค้า', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrderBillStatusPage()),
                                );
                              },
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.description, size: 40, color: Colors.grey,),
                                  Text('บิลรายการสั่งซื้อ')
                                ],
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Icon(Icons.playlist_add_check, size: 40, color: Colors.grey,),
                                Text('สินค้าสั่งประจำ')
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Icon(Icons.comment, size: 40, color: Colors.grey,),
                                Text('ข้อเสนอแนะ')
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Icon(Icons.help, size: 40, color: Colors.grey,),
                                Text('คู่มือการใช้งาน')
                              ],
                            )
                          ],
                        ),
                      ),
                      MaterialButton(
                        color: Colors.amber,
                        textColor: Colors.white,
                        minWidth: double.infinity,
                        height: 50,
                        child: Text(
                          "อัปเดต ฐานข้อมูล",
                          style: new TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        //onPressed: (){Navigator.pushReplacementNamed(context, '/Home');},
                        onPressed: () {
                          _showDialogDrop();
                          //addToOrder();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      MaterialButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        minWidth: double.infinity,
                        height: 50,
                        child: Text(
                          "ออกจากระบบ",
                          style: new TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        //onPressed: (){Navigator.pushReplacementNamed(context, '/Home');},
                        onPressed: () {
                          _showDialogExit();
                          //addToOrder();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
