import 'dart:async';
import 'dart:js';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:wang_shop/order_bill_temps_model.dart';

import 'package:wang_shop/database_helper.dart';
import 'package:background_fetch/background_fetch.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:wang_shop/home.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState>{
  NotificationBloc(NotificationState initialState) : super(initialState);

  @override
  NotificationState get initialState => InitialNotificationState();
  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List <OrderBillTemps>orderBillTempsAll = [];
  String? userCode;

  var orderBillStatusText;

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE
    ), () async {
      // This is the fetch-event callback.
      print('[BackgroundFetch] Event received');

      getOrderBillTemps();

      // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
      // for taking too long in the background.
      //BackgroundFetch.finish();
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');

    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;
  }

  getOrderBillTemps() async{

    orderBillTempsAll = [];

    var resUser = await databaseHelper.getList();
    //setState(() {
      userCode = resUser[0]['code'];
    //});

    print(userCode);

    final res = await http.get(Uri.https('wangpharma.com', '/API/orderBill.php', {'orderBillCus': userCode, 'act':'CheckStatusOrderBill'}));

    if(res.statusCode == 200){

      //setState(() {
        //isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBillTemps) => orderBillTempsAll.add(OrderBillTemps.fromJson(orderBillTemps)));

        print(orderBillTempsAll);

        loopSendOrderBillNotification();

        //return orderBillTempsAll;

      //});


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
  }

  void setupNotificationPlugin(){
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = new AndroidInitializationSettings('ic_notification');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: onSelectNotification);
        /*onSelectNotification: onSelectNotification).then((init){
            setupNotification();
        });*/
  }

  Future onDidReceiveLocalNotification(int? id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
        context: context as BuildContext,
        builder: (BuildContext context) => AlertDialog(
          content: Text("ระบบแจ้งเตือนสถานะรายการบิล"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    /*await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );*/
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

    var scheduledNotificationDateTime = new DateTime.now().add(new Duration(seconds: 5));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails('your other channel id', 'your other channel name', 'your other channel description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        index,
        'รายการบิลเลขที่:$orderBillCode',
        'สถานะ:$orderBillStatusText',
        //scheduledNotificationDateTime,
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
  }

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    if(event is setUpNotification){

    }else if (event is checkStatusNotification) {

    }
  }
}