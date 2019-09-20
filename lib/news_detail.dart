import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class newsDetailPage extends StatefulWidget {

  var news;
  newsDetailPage({Key key, this.news}) : super(key: key);

  @override
  _newsDetailPageState createState() => _newsDetailPageState();
}

class _newsDetailPageState extends State<newsDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text(widget.product.productName.toString()),
        title: Text("รายละเอียดข่าว"),
        actions: <Widget>[
          /*IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: (){
                //Navigator.pushReplacementNamed(context, '/Order');
              }
          )*/
        ],
      ),
    );
  }
}
