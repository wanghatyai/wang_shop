import 'package:flutter/material.dart';

class SummaryOrderPage extends StatefulWidget {
  @override
  _SummaryOrderPageState createState() => _SummaryOrderPageState();
}

class _SummaryOrderPageState extends State<SummaryOrderPage> {

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('สรุปรายการสั่งจอง'),
        actions: <Widget>[
        ],
      ),
      body: Container(
        child: Text('รายละเอียดสินค้า'),
      ),
    );
  }
}
