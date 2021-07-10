import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


import 'package:wang_shop/database_helper.dart';
import 'package:wang_shop/member_model.dart';

import 'package:package_info/package_info.dart';
import 'package:wang_shop/pay_dialog.dart';
import 'package:wang_shop/ship_dialog.dart';
import 'package:wang_shop/summary_order.dart';



class CheckOutPage extends StatefulWidget {
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  DatabaseHelper databaseHelper = DatabaseHelper.internal();
  //FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  var userID;
  var userCode;

  //List <OrderBillTemps>orderBillTempsAll = [];

  List <Member>memberAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Member";
  double heightValForDevice30 = 2000;

  //Timer timerLoopCheck;
  //var orderBillStatusText;

  String? appName;
  String? packageName;
  String? version;
  String? buildNumber;

  final formatter = new NumberFormat("#,##0.00");

  List user = [];
  String? name;
  String? value;
  String? userRoute;
  DateFormat? dateFormat;
  Map<String, dynamic> transportationDetail = {};

  List ordersFree = [];
  List orders = [];
  var sumAmount = 0.0;
  var freeLimit = 0.0;

  var priceNowAll = [];

  getTransportation() async {

    var res = await databaseHelper.getList();
    //print(res);

    setState(() {
      user = res;
      name = user[0]['name'];
      userCode = user[0]['code'];
      userRoute = user[0]['route'];
    });

    final resTransportation = await http.get(Uri.https('wangpharma.com', '/API/transportation.php', {'userRoute': userRoute, 'act':'TransportationDate'}));

    if(resTransportation.statusCode == 200){

      var jsonData = json.decode(resTransportation.body);

      if(jsonData.isNotEmpty){

        setState(() {
          transportationDetail = jsonData[0];
        });

        print('TransportationDay--${jsonData.length}');
        var newDateTimeObj2 = DateFormat('yyyy-MM-dd').parse(transportationDetail['Start_In_calendar']);
        print('TransportationDay data query ${transportationDetail['Start_In_calendar']}');
        //dateFormate = DateFormat("dd-MM-yyyy").format(DateTime.parse("2019-09-30"));
        //dateFormat.format(newDateTimeObj2);
        //print(DateFormat("dd-MM-yyyy").format(DateFormat('yyyy-MM-dd').parse(transportationDetail['Start_In_calendar'])));
        //print(DateFormat('yyyy-MM-dd').parse(overdueBillAllDetail['CBS_Date_Receive']));
        //var newDateTimeObj2 = new DateFormat("dd/MM/yyyy HH:mm:ss").parse("10/02/2000 15:13:09")
      }else{
        print('no date TransportationDay');
      }

    }

    /*if(overdueStatus > 0) {
      this.showDialogOverdue();
    }*/

    //return overdueBillAllDetail;

  }

  getOrderAll() async{

    var resFree = await databaseHelper.getOrderFree();
    var res = await databaseHelper.getOrder();
    var resUser = await databaseHelper.getList();

    var userCredit;

    userCredit = resUser[0]['credit'];

    var priceCredit;
    var priceNow;

    var unitQty1;
    var unitQty2;
    var unitQty3;


    print(resFree);
    print(res);
    print('User$userCredit');

    res.forEach((order) {

      unitQty1 = (order['unitQty1']/order['unitQty1']);
      unitQty2 = (order['unitQty1']/order['unitQty2']);
      unitQty3 = (order['unitQty1']/order['unitQty3']);


      if(order['proStatus'] == 2 && order['amount'] >= order['proLimit']){
        priceCredit = order['priceA'];
      }else{
        if(userCredit == 'A'){
          priceCredit = order['priceA'];
        }else if(userCredit == 'B'){
          priceCredit = order['priceB'];
        }else{
          priceCredit = order['priceC'];
        }
      }


      if(order['unitStatus'] == 1){

        sumAmount = sumAmount + ((priceCredit * unitQty1) * order['amount']);
        priceNow = priceCredit*unitQty1;
        priceNowAll.add(priceNow);

        print('----$priceNow');

      }

      if(order['unitStatus'] == 2){

        sumAmount = sumAmount + ((priceCredit * unitQty2) * order['amount']);
        priceNow = priceCredit*unitQty2;
        priceNowAll.add(priceNow);

        print('----$priceNow');

      }

      if(order['unitStatus'] == 3){

        sumAmount = sumAmount + ((priceCredit * unitQty3) * order['amount']);
        priceNow = priceCredit*unitQty3;
        priceNowAll.add(priceNow);

        print('----$priceNow');

      }

    }
    );

    freeLimit = sumAmount*0.01;
    if(freeLimit.toInt() >= 30){
      print('แต้ม-${freeLimit.toInt()}');
    }

    print(priceNowAll);

    setState(() {
      ordersFree = resFree;
      orders = res;
    });
  }


  _launchURL() async {
    const urlHelp = "https://www.youtube.com/watch?v=YFo2mB1kMko";
    if (await canLaunch(urlHelp)) {
      await launch(urlHelp);
    } else {
      throw 'Could not launch $urlHelp';
    }
  }

  _urlSupportApp() async {
    const urlHelp = "https://line.me/R/ti/g/HvYpu6C7ka";
    if (await canLaunch(urlHelp)) {
      await launch(urlHelp);
    } else {
      throw 'Could not launch $urlHelp';
    }
  }

  getInfoApp() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  getUser() async{

    var resUser = await databaseHelper.getList();
    setState(() {
      userID = resUser[0]['idUser'];
    });

    print(userID);

    final res = await http.get(Uri.https('wangpharma.com', '/API/member.php', {'userID': userID, 'act': 'Member'}));


    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => memberAll.add(Member.fromJson(products)));

        print(memberAll);

      });

      return memberAll;


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
    getInfoApp();
    getOrderAll();
    getTransportation();
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


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,

        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.deepOrange),
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            "ทำการสั่งจอง",
            style: TextStyle(color: Colors.deepOrange, fontSize: 14),
          ),
        ),
        body: Builder(builder: (context) {
          return Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: ListView(
                    children: <Widget>[
                      selectedAddressSection(),
                      //ProductInCart(),
                      standardDelivery(),
                      //checkoutItem(),
                      priceSection()
                    ],
                  ),
                ),
                flex: 90,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,

                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: RaisedButton(
                    onPressed: (){

                      Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryOrderPage()));
                    },
                    child: Text(
                      "ต่อไป",
                    ),
                    color: Colors.red[600],
                    textColor: Colors.white,
                  ),
                ),
                flex: 10,
              )
            ],
          );
        }),
      ),
    );
  }



  selectedAddressSection() {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined,color: Colors.red,),
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(
                          "${memberAll[0].memberName}",
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                    EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    child: Text(
                      "ร้านค้า/คลินิก",
                    ),
                  )
                ],
              ),
              createAddressText(
                  "${memberAll[0].memberAddress}", 16),
              SizedBox(
                height: 6,
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: "",
                  ),
                  TextSpan(
                    text: "",
                  ),
                ]),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                color: Colors.grey.shade300,
                height: 1,
                width: double.infinity,
              ),
              //addressAction()
            ],
          ),
        ),
      ),
    );
  }

  createAddressText(String strAddress, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        strAddress,
      ),
    );
  }

  addressAction() {
    return Container(
      child: Row(
        children: <Widget>[
          Spacer(
            flex: 2,
          ),
          FlatButton(
            onPressed: () {},
            child: Text(
              "แก้ไข",
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Spacer(
            flex: 3,
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey,
          ),
          Spacer(
            flex: 3,
          ),
          FlatButton(
            onPressed: () {},
            child: Text("เพิ่มที่อยู่",
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }

  /*ProductInCart(){
    return ListView.builder(
        //separatorBuilder: (context, index) => Divider(
        //color: Colors.black,
        //),
        itemBuilder: (context, int index){
          return Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
              leading: Stack(
                children: <Widget>[
                  Image.network('https://www.wangpharma.com/cms/product/${orders[index]['pic']}',fit: BoxFit.cover, width: 70, height: 70,),
                  (orders[index]['proStatus'] == 2)?
                  Container(
                    padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                    width: 30,
                    height: 20,
                    color: Colors.red,
                    child: Text('Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  ) : Container(
                    padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                    width: 30,
                    height: 20,
                  )
                ],
              ),
              title: Text('${orders[index]['name']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${orders[index]['code']}'),
                  Text('จำนวนที่สั่ง ${orders[index]['amount']} : ${orders[index]['unit']}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),),
                  Text("ราคาต่อหน่วย ฿${priceNowAll[index]}", style: TextStyle(color: Colors.blueGrey),),
                ],
              ),
              trailing: Text('฿${formatter.format(priceNowAll[index]*orders[index]['amount'])}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ),//ราคารวมการสั่งซื้อ
          );
        },
        itemCount: orders != null ? orders.length : 0,
    );
  }*/

  standardDelivery() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border:
          Border.all(color: Colors.tealAccent.withOpacity(0.4), width: 1),
          color: Colors.tealAccent.withOpacity(0.2)),
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Text(
                "  ตัวเลือกการจัดส่ง",style: TextStyle(color: Colors.teal),
              ),
              Divider(
                color: Colors.tealAccent.shade400.withOpacity(0.5),
              ),
            ],
          ),
          ShipDialogPage(),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Radio(
                value: 1,
                groupValue: 1,
                onChanged: (isChecked) {},
                activeColor: Colors.tealAccent.shade400,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Wang Delivery",
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "บริการขนส่งโดยรถวังเภสัช | Free Delivery",
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ],
          ),*/
        ],
      ),
    );
  }

  /*checkoutItem() {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: ListView.builder(
            itemBuilder: (context, position) {
              return checkoutListItem();
            },
            itemCount: 3,
            shrinkWrap: true,
            primary: false,
            scrollDirection: Axis.vertical,
          ),
        ),
      ),
    );
  }*/

  /*checkoutListItem() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Container(
            child: Image(
              image: AssetImage(
                "images/details_shoes_image.webp",
              ),
              width: 35,
              height: 45,
              fit: BoxFit.fitHeight,
            ),
            decoration:
            BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
          ),
          SizedBox(
            width: 8,
          ),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "Estimated Delivery : ",),
              TextSpan(
                  text: "21 Jul 2019 ",
                 )
            ]),
          )
        ],
      ),
    );
  }*/

  priceSection() {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container( decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40
                        ) ,
                        border: Border.all(
                          width: 2,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                          child: Icon(Icons.attach_money_sharp,color: Colors.deepOrangeAccent,)),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        "วิธีการชำระเงิน",
                      ),
                    ],
                  ),

                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: (){
                      selectPay();
                    },),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              createPriceItem(
                  "รวมการสั่งซื้อ ", " ฿${formatter.format(sumAmount)}", Colors.teal.shade300),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "การจัดส่ง",
                  ),
                  Row(
                    children: [
                      Text(
                        "฿0.00",
                        style: TextStyle(color: Colors.deepOrange, fontSize: 14),
                      ),
                      Text(
                        "฿40.00",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "ยอดชำระทั้งหมด",style: TextStyle(fontSize: 16),
                  ),
                  Text(
                      '฿${formatter.format(sumAmount)}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "แต้มสะสม",
                  ),
                  Text(
                    '${freeLimit.toInt()} แต้ม',style: TextStyle(color: Colors.deepOrange[500],fontWeight: FontWeight.bold),),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  selectPay(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: Text('เลือกวิธีชำระเงิน'),
        children: <Widget>[
          //Text('จำนวน'),
          Divider(
            color: Colors.black,
          ),
          SizedBox(
            height: 30,
          ),
          PayDialogPage(),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: SimpleDialogOption(
                  onPressed: (){
                    Navigator.pop(context);
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryOrderPage()));
                  },
                  child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.pink[400]!.withOpacity(0.95),Colors.orange[600]!.withOpacity(0.95)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                                'กลับ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18, fontWeight: FontWeight.bold
                                )
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ),
              Expanded(
                child: SimpleDialogOption(
                  onPressed: (){

                    Navigator.push(context, MaterialPageRoute(builder: (context) => CheckOutPage()));
                  },
                  child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.teal[400]!.withOpacity(0.95),Colors.green[600]!.withOpacity(0.95)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                                'ตกลง',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18, fontWeight: FontWeight.bold
                                )
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ),
            ],
          )
        ],


      );
    });
  }

  createPriceItem(String key, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            key,
          ),
          Text(
            value,

          )
        ],
      ),
    );
  }
}