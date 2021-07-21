import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wang_shop/home.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wang_shop/database_helper.dart';

import 'package:wang_shop/order.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';
//import 'package:wang_shop/bloc_count_order_all.dart';

import 'package:background_fetch/background_fetch.dart';

//GlobalKey<_HomeState> _homeState = new GlobalKey();

/// This "Headless Task" is run when app is terminated.
backgroundFetchHeadlessTask() async {

  print('[BackgroundFetch] Headless event received.');
  print('[BackgroundFetch] notification test.');
  //Home().testPrint();
  Home().createState().orderBillStatusNotificationBG();
  //Home().createState().testPrint();
  //Home().createState().getOrderBillTemps();
  //new Home( getOrderBillTemps: getOrderBillTemps );
  //BackgroundFetch.finish();
}

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'Promotion', // id
  'แจ้งเตือนโปรโมชั่น', // title
  'แจ้งเตือนโปรโมชั่นและข่าวด่วนสุดพิเศษ', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  DatabaseHelper databaseHelper = DatabaseHelper.internal();
  databaseHelper.initDatabase();
  databaseHelper.initDatabaseOrder();
  databaseHelper.initDatabaseOrderFree();
  databaseHelper.initDatabaseShipAndPay();
  databaseHelper.initDatabaseOrderTemps();
  //databaseHelper.dropTableOrder();

  //Home().createState().testPrint();

  runApp(MyApp());

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        bloc: BlocCountOrder(),
        child:  MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WangPharma',
          routes: <String,WidgetBuilder>{
            '/Main': (BuildContext context) => MyApp(),
            '/Home': (BuildContext context) => Home(),
            '/Order': (BuildContext context) => OrderPage(),
          },
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.green,
          ),
          home: LoginPage(),
        ),
     );
  }
}

class LoginPage extends StatefulWidget{
  @override
  State createState() => new LoginPageState();

}

class LoginPageState extends State<LoginPage>{

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  //final _loginForm = GlobalKey<FormState>();

  TextEditingController ctrlUser = TextEditingController();
  TextEditingController ctrlPass = TextEditingController();

  bool _showPass = false; // กำหนดสถานะ ShowPass = false;

  var userAlert = 'Please enter the Username / กรุณากรอกชื่อบัญชีผู้';
  var passAlert = 'Please enter the Password / กรุณากรอกรหัสผ่านบัญชีผู้ใช้';
  var userInvalid = false;
  var passInvalid = false;

  void _showAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'),
        );
      },
    );
  }

  /*_saveData(key, val) async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      prefer.setString(key, val);
    });
  }*/
  _checkMemberOnDB() async{
    var checkMemberOnDB = await databaseHelper.getMemberCheckCount();
    //var memberVal = await databaseHelper.getList();
    print(checkMemberOnDB[0]['checkID']);
    //print(memberVal);

    if(checkMemberOnDB[0]['checkID'] == 1){
      Navigator.pushReplacementNamed(context, '/Home');
    }

  }

  _doLogin() async{

    //SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
        Uri.parse('https://wangpharma.com/API/login.php'),
        body: {'usr': ctrlUser.text, 'pss': ctrlPass.text});

    if(response.statusCode == 200){
      var jsonResponse = json.decode(response.body);
      //print(jsonResponse['error']);

      if(jsonResponse['error']=='0'){

        //prefs.setString("IDuser", jsonResponse['iduser']);
        
        Map user = {
          'idUser': jsonResponse['iduser'],
          'code': jsonResponse['ccode'],
          'name': jsonResponse['name'],
          'credit': jsonResponse['credit'],
          'route': jsonResponse['route'],
        };

        var checkMember = await databaseHelper.getMemberCheck(user['code']);

        if(checkMember.isEmpty){

          await databaseHelper.removeAll();
          await databaseHelper.removeAllOrderFree();
          await databaseHelper.removeAllMember();
          await databaseHelper.saveData(user);
          Navigator.pushReplacementNamed(context, '/Home');
        }else{
          Map userCredit = {
            'idUser': jsonResponse['iduser'],
            'credit': jsonResponse['credit'],
            'route': jsonResponse['route'],
          };

          await databaseHelper.updateDataCreditAndRoute(userCredit);

          //await databaseHelper.saveData(user);
          Navigator.pushReplacementNamed(context, '/Home');
        }

        //var resDB = await databaseHelper.getList();
        //print(resDB);

        //await databaseHelper.saveData(user);

        //_saveData('name', jsonResponse['name']);
        //_saveData('code', jsonResponse['ccode']);

        //Navigator.pushReplacementNamed(context, '/Home');
      }else{
        _showAlert();
      }

    }else{
      print('Connect ERROR');
    }
  }

  // เมื่อกดแสดงรหัสผ่านที่ตัวเองกด
  void clickShowPassword() {
    setState ( () {
      _showPass = !_showPass;
    } );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkMemberOnDB();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      //backgroundColor: Colors.green,
      //resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: Container (
          padding: EdgeInsets.fromLTRB ( 30, 0, 30, 40 ),
          // ซ้าย , บน , ขวา , ล่าง
          //constraints: BoxConstraints.expand ( ),
          color: Colors.white,
          child: Column (
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding (
                padding: const EdgeInsets.fromLTRB( 0, 0, 0, 25 ),
                child: Container (
                  width: 100,
                  height: 100,
                  padding: EdgeInsets.all ( 5 ),
                  decoration: BoxDecoration (
                    shape: BoxShape.circle,
                    color: Color ( 0xffd8d8d8 ),
                  ),
                  //child: FlutterLogo(),
                  child: Image (
                    image: AssetImage ( "assets/logo-login.png" ),
                  ),
                ),
              ),
              Padding (
                padding: const EdgeInsets.fromLTRB( 0, 0, 0, 20 ),
                child: Text (
                  'Wangpharmacy\nกรุณาเข้าสู่ระบบ Login',
                  style: TextStyle (
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 30.0,
                  ),
                ),
              ),
              Padding (
                padding: const EdgeInsets.fromLTRB( 0, 0, 0, 40 ),
                child: TextFormField (
                  controller: ctrlUser,
                  style: TextStyle (
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration (
                      prefixIcon: Icon (
                        Icons.account_box,
                        size: 30,
                      ),
                      labelText: 'Username / ชื่อบัญชีผู้ใช้',
                      errorText: userInvalid ? userAlert : null,
                      //'Please enter the Username / กรุณากรอกชื่อบัญชีผู้',
                      labelStyle: TextStyle (
                        color: Color ( 0xff888888 ),
                        fontSize: (15),
                      )
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding (
                padding: const EdgeInsets.fromLTRB( 0, 0, 0, 40 ),
                child: Stack (
                  alignment: AlignmentDirectional.centerEnd,
                  children: <Widget>[
                    TextField (
                      controller: ctrlPass,
                      style: TextStyle (
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      obscureText: !_showPass,
                      decoration: InputDecoration (
                        prefixIcon: Icon (
                          Icons.vpn_lock,
                          size: 30,
                        ),
                        labelText: 'Password / รหัสผ่านบัญชีผู้ใช้',
                        errorText: passInvalid ? passAlert : null,
                        labelStyle: TextStyle (
                          color: Color ( 0xff888888 ),
                          fontSize: 15,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    GestureDetector (
                      onTap: clickShowPassword,
                      child: Text (
                        _showPass ? 'Hide' : 'Show',
                        style: TextStyle (
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding (
                padding: const EdgeInsets.fromLTRB( 0, 0, 0, 40 ),
                child: SizedBox (
                  width: double.infinity,
                  height: 56,
                  child: RaisedButton (
                    color: Colors.green,
                    shape: RoundedRectangleBorder (
                      borderRadius: BorderRadius.all (
                        Radius.circular ( 10 ),
                      ),
                    ),
                    onPressed: _doLogin,
                    child: Text (
                      'เข้าสู่ระบบ',
                      style: TextStyle (
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox (
                height: 30,
              ),
              Row(
                children: <Widget>[
                  Icon(
                      Icons.settings
                  ),
                  FlatButton(
                    onPressed: () {

                      databaseHelper.dropTableOrder();
                      databaseHelper.dropTableOrderFree();
                      databaseHelper.dropTableMembers();
                      databaseHelper.dropTableShipAndPay();

                      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    },
                    child: Text("อัปเดตฐานข้อมูล", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
