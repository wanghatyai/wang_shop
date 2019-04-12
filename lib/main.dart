import 'package:flutter/material.dart';
import 'package:wang_shop/home.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wang_shop/database_helper.dart';

import 'package:wang_shop/order.dart';


void main() {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();
  databaseHelper.initDatabase();
  databaseHelper.initDatabaseOrder();
  databaseHelper.initDatabaseShipAndPay();
  //databaseHelper.dropTableOrder();

  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WangShop',
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
          title: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'),
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
          'code': jsonResponse['ccode'],
          'name': jsonResponse['name'],
        };

        var checkMember = await databaseHelper.getMemberCheck(user['code']);

        if(checkMember.isEmpty){

          await databaseHelper.removeAll();
          await databaseHelper.removeAllMember();
          await databaseHelper.saveData(user);
          Navigator.pushReplacementNamed(context, '/Home');
        }else{
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
                  color: Colors.blue,
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
                        color: Colors.blue,
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
                  color: Colors.blue,
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
              height: 100.0,
            ),
          ],
        ),
      ),
    );
  }
}




class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
