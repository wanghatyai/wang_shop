import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:wang_shop/bloc_count_order_all.dart';


void main() {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();
  databaseHelper.initDatabase();
  databaseHelper.initDatabaseOrder();
  databaseHelper.initDatabaseOrderFree();
  databaseHelper.initDatabaseShipAndPay();
  //databaseHelper.dropTableOrder();

  runApp(MyApp());

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

  final _loginForm = GlobalKey<FormState>();

  TextEditingController ctrlUser = TextEditingController();
  TextEditingController ctrlPass = TextEditingController();

  bool _ShowPass = false; // กำหนดสถานะ ShowPass = false;

  var Useralert = 'Please enter the Username / กรุณากรอกชื่อบัญชีผู้';
  var Passalert = 'Please enter the Password / กรุณากรอกรหัสผ่านบัญชีผู้ใช้';
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

  _doLogin() async{
    final response = await http.post(
      'http://wangpharma.com/API/login.php',
      body: {'usr': ctrlUser.text, 'pss': ctrlPass.text});

    if(response.statusCode == 200){
      var jsonResponse = json.decode(response.body);
      //print(jsonResponse['error']);

      if(jsonResponse['error']=='0'){
        
        Map user = {
          'idUser': jsonResponse['iduser'],
          'code': jsonResponse['ccode'],
          'name': jsonResponse['name'],
          'credit': jsonResponse['credit'],
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
          };

          await databaseHelper.updateDataCredit(userCredit);
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
  void ClickShowpassword() {
    setState ( () {
      _ShowPass = !_ShowPass;
    } );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      //backgroundColor: Colors.green,
      resizeToAvoidBottomPadding: false,
      body: Container (
        padding: EdgeInsets.fromLTRB ( 30, 0, 30, 40 ),
        // ซ้าย , บน , ขวา , ล่าง
        constraints: BoxConstraints.expand ( ),
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
                    errorText: userInvalid ? Useralert : null,
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
                    obscureText: !_ShowPass,
                    decoration: InputDecoration (
                      prefixIcon: Icon (
                        Icons.vpn_lock,
                        size: 30,
                      ),
                      labelText: 'Password / รหัสผ่านบัญชีผู้ใช้',
                      errorText: passInvalid ? Passalert : null,
                      labelStyle: TextStyle (
                        color: Color ( 0xff888888 ),
                        fontSize: 15,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  GestureDetector (
                    onTap: ClickShowpassword,
                    child: Text (
                      _ShowPass ? 'Hide' : 'Show',
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
              height: 70,
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
                  child: Text("แก้ไขปัญหา"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
