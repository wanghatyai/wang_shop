import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class getProductFreePage extends StatefulWidget {

  var score;
  getProductFreePage({Key key, this.score}) : super (key: key);

  @override
  _getProductFreePageState createState() => _getProductFreePageState();
}

class _getProductFreePageState extends State<getProductFreePage> {

  List productFree = [];

  getProduct() async{

    final res = await http.get('http://wangpharma.com/API/product.php?Score=${widget.score}&act=Free');

    if(res.statusCode == 200){

      setState(() {
        //isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => productFree.add(products));
        //perPage = productFree.length;

        print(productFree);
        print(productFree.length);

        return productFree;

      });


    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Text('getFreeProduct');
  }
}
