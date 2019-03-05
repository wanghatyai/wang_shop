import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class productDetailPage extends StatefulWidget {

  var product;
  productDetailPage({Key key, this.product}) : super(key: key);

  @override
  _productDetailPageState createState() => _productDetailPageState();
}

class _productDetailPageState extends State<productDetailPage> {
  @override

  Widget build(BuildContext context) {

    //print(widget.product);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['nproductMain'].toString()),
      ),
      body: Column(
        children: <Widget>[
          Image.network('http://www.wangpharma.com/cms/product/${widget.product['pic']}',fit: BoxFit.contain, width:double.infinity, height: 250,),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
                widget.product['nproductMain'].toString(),
                style: new TextStyle(
                  fontSize: 16
              ),
            ),
          ),
          Text(widget.product['nproductENG'].toString()),
          MaterialButton(
            color: Colors.deepOrange,
            textColor: Colors.white,
            minWidth: double.infinity,
            height: 50,
            child: Text(
              "หยิบใส่ตะกร้า",
              style: new TextStyle(
                  fontSize: 20
              ),
            ),
            //onPressed: (){Navigator.pushReplacementNamed(context, '/Home');},
            onPressed: () {
            },
          )
        ],
      ),
    );

  }
}

