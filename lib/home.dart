import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wang_shop/home_new.dart';
import 'package:wang_shop/main.dart';
import 'package:wang_shop/member.dart';
import 'package:wang_shop/product_pro.dart';
import 'package:wang_shop/product_hot.dart';
import 'package:wang_shop/product_new.dart';
import 'package:wang_shop/product_recom.dart';
import 'package:wang_shop/product_wish.dart';
import 'package:wang_shop/product_category.dart';

import 'package:wang_shop/product_model.dart';

import 'package:wang_shop/database_helper.dart';
import 'package:wang_shop/order.dart';

import 'package:wang_shop/search_auto_out.dart';

import 'package:wang_shop/news.dart';

import 'package:wang_shop/order_bill_status.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wang_shop/order_bill_temps_model.dart';

import 'package:background_fetch/background_fetch.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'package:in_app_update/in_app_update.dart';

class Home extends StatefulWidget {

  //Home({Key key}) : super(key: key);

  //final getOrderBillTemps = new Home().getOrderBillTemps();
  //const Home({Key key, this.getOrderBillTemps}) : super(key: key);
  //final Function testPrint;
  //Home({Key key, this.testPrint}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {

  AppUpdateInfo _updateInfo;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

  List <OrderBillTemps>orderBillTempsAll = [];

  List<Product> _product = [];
  String barcode;

  //Timer timerLoopCheck;
  var orderBillStatusText;

  DateFormat dateFormat;
  //DateFormat timeFormat;

  var countOrderAll;

  //List<DateTime> _events = [];

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  testPrint(){
    print('testestttttt');
  }

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
    final resOverdue = await http.get('https://wangpharma.com/API/overduePopup.php?act=Overdue&userCode=$userCode');

    //print('https://wangpharma.com/API/overduePopup.php?act=Overdue&userCode=$userCode');

    if(resOverdue.statusCode == 200){

        //print(resOverdue);

        var jsonData = json.decode(resOverdue.body);

        //print('getOverdue-----$jsonData');

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

    }

    print(overdueStatus);

    if(overdueStatus > 0) {
      this.showDialogOverdue();
    }

    //return overdueBillAllDetail;

  }

  searchProduct(searchVal) async{

    _product.clear();

    //productAll = [];

    final res = await http.get('https://wangpharma.com/API/product.php?SearchVal=$searchVal&act=Search');

    if(res.statusCode == 200){

      setState(() {

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => _product.add(Product.fromJson(products)));

        //products = json.decode(res.body);
        //recentProducts = json.decode(res.body);
        /*jsonData.forEach(([product, i]) {
          if(product['nproductMain'] != 'null'){
            products.add(product['nproductMain']);
          }
          print(product['nproductMain']);
        });*/
        print(_product);
        return _product;

      });

    }else{
      throw Exception('Failed load Json');
    }
    //print(searchVal);
    //print(json.decode(res.body));
  }

  scanBarcode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState((){
        this.barcode = barcode;
        searchProduct(this.barcode);

        Future.delayed(Duration(seconds: 2), () {
          //if(overdueStatus > 0) {
          //this.showDialogOverdue();
          print(_product[0]);
          addToOrderFast(_product[0]);
          //}
        });
        scanBarcode();
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _showAlertBarcode();
        print('Camera permission was denied');
      } else {
        print('Unknow Error $e');
      }
    } on FormatException {
      print('User returned using the "back"-button before scanning anything.');
    } catch (e) {
      print('Unknown error.');
    }
  }

  void _showAlertBarcode() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('คุณไม่เปิดอนุญาตใช้กล้อง'),
        );
      },
    );
  }

  /*_launchURL() async {
    const urlHelp = "https://www.youtube.com/watch?v=CQni6VdSdTs";
    if (await canLaunch(urlHelp)) {
      await launch(urlHelp);
    } else {
      throw 'Could not launch $urlHelp';
    }
  }*/

  _checkUpdateApp() async{
    if(Platform.isAndroid){
        print('Device is Android check for Update');
        checkForUpdate();
    }else{
      print('Device is IOS check for Update');
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });

      if(_updateInfo?.updateAvailable == true){

        InAppUpdate.startFlexibleUpdate().then((_) {
          print('Now StartUpdate');

          databaseHelper.dropTableOrder();
          databaseHelper.dropTableOrderFree();
          databaseHelper.dropTableMembers();
          databaseHelper.dropTableShipAndPay();

        }).catchError((e) => print(e));

      }else{
        print('no update');
      }

    }).catchError((e) => print(e));
  }

  @override
  void initState(){
    super.initState();
    getUser();
    setupNotif();
    initializeDateFormatting();

    dateFormat = new DateFormat.yMMMMd('th');
    //timeFormat = new DateFormat.Hms('cs');
    //getOverdue();

      Future.delayed(Duration(seconds: 3), () {
        //add notify order
        blocCountOrder.getOrderCount();
        //if(overdueStatus > 0) {
          //this.showDialogOverdue();
          getOverdue();
        //}
      });

    Future.delayed(Duration(seconds: 6), () {
      _checkUpdateApp();
    });

    setupNotificationPlugin();

    //getOrderBillTemps();
    initPlatformState();

    //getOrderBillTemps();

    //timerLoopCheck = Timer.periodic(Duration(seconds: 15), (Timer t) => getOrderBillTemps());
    //Timer.periodic(Duration(seconds: 15), (Timer t) => getOrderBillTemps());
    Future.delayed(Duration(seconds: 10), () => getOrderBillTemps());

    //_clearOrderTempsDB();
    orderBillStatusNotificationBG();

  }

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
    if (!mounted) return;
  }

  orderBillStatusNotificationBG(){
    BackgroundFetch.start().then((int status) {
      getOrderBillTemps();
      print('[BackgroundFetch] start success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] start FAILURE: $e');
    });
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

  getOrderBillTemps() async{

    orderBillTempsAll = [];

    var resUser = await databaseHelper.getList();
    setState(() {
      userCode = resUser[0]['code'];
    });

    print(userCode);

    final res = await http.get('https://wangpharma.com/API/orderBill.php?orderBillCus=$userCode&act=CheckStatusOrderBill');
    if(res.statusCode == 200){

      setState(() {
        //isLoading = false;

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

      Future.delayed(Duration(seconds: 2), () async{
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
      });

    }
  }

  void setupNotificationPlugin(){
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
      MaterialPageRoute(builder: (context) => Home()),
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

    var scheduledNotificationDateTime = new DateTime.now().add(new Duration(seconds: 5));
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
  void dispose() {
    //timerLoopCheck?.cancel();
    super.dispose();
  }

  /*_clearOrderTempsDB()async{
    await databaseHelper.removeAllOrderTemps();
  }*/

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

    /*Widget drawer = Drawer(
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
    );*/

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        //title: Text("${name}"),
        leading: IconButton(
            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
            icon: Column(
              children: <Widget>[
                Icon(Icons.crop_free, color: Colors.white, size: 40,),
                Text('สแกน', style: TextStyle(fontSize: 12),)
              ],
            ),
            onPressed: (){
              scanBarcode();
              //searchAutoOutPage().createState().scanBarcode();
            }
        ),
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

  addToOrderFast(productFast) async{

    var unit1;
    var unit2;
    var unit3;

    int amount;

    if(productFast.productUnit1.toString() != "null"){
      unit1 = productFast.productUnit1.toString();
    }else{
      unit1 = 'NULL';
    }
    if(productFast.productUnit2.toString() != "null"){
      unit2 = productFast.productUnit2.toString();
    }else{
      unit2 = 'NULL';
    }
    if(productFast.productUnit3.toString() != "null"){
      unit3 = productFast.productUnit3.toString();
    }else{
      unit3 = 'NULL';
    }

    if(productFast.productProLimit != "" && productFast.productProStatus == '2'){

      if(int.parse(productFast.productProLimit) > 0){
        amount = int.parse(productFast.productProLimit);
      }else{
        amount = 1;
      }

    }else{
      amount = 1;
    }

    Map order = {
      'productID': productFast.productId.toString(),
      'code': productFast.productCode.toString(),
      'name': productFast.productName.toString(),
      'pic': productFast.productPic.toString(),
      'unit': productFast.productUnit1.toString(),
      'unitStatus': 1,
      'unit1': unit1,
      'unitQty1': productFast.productUnitQty1,
      'unit2': unit2,
      'unitQty2': productFast.productUnitQty2,
      'unit3': unit3,
      'unitQty3': productFast.productUnitQty3,
      'priceA': productFast.productPriceA,
      'priceB': productFast.productPriceB,
      'priceC': productFast.productPriceC,
      'amount': amount,
      'proStatus': productFast.productProStatus,
      'proLimit': amount,
    };

    var checkOrderUnit = await databaseHelper.getOrderCheck(order['code'], order['unit']);

    //print(checkOrderUnit.isEmpty);

    if(checkOrderUnit.isEmpty){

      //print(order);
      await databaseHelper.saveOrder(order);

      showToastAddFast();


      //add notify order
      blocCountOrder.getOrderCount();

    }else{

      var sumAmount = checkOrderUnit[0]['amount'] + amount;
      Map order = {
        'id': checkOrderUnit[0]['id'],
        'unit': checkOrderUnit[0]['unit'],
        'unitStatus': 1,
        'amount': sumAmount,
      };

      await databaseHelper.updateOrder(order);

      showToastAddFast();


      //add notify order
      blocCountOrder.getOrderCount();

    }

    //Navigator.pushReplacementNamed(context, '/Home');

  }

  showToastAddFast(){
    Fluttertoast.showToast(
        msg: "เพิ่มรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3
    );
  }

}



