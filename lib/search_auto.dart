import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class searchAutoPage extends StatefulWidget {
  @override
  _searchAutoPageState createState() => _searchAutoPageState();
}

class _searchAutoPageState extends State<searchAutoPage> {

  bool loading = true;
  var productAll = [];

  searchProduct(searchVal) async{

    //productAll = [];

    final res = await http.get('http://wangpharma.com/API/product.php?SearchVal=$searchVal&act=Search');

    if(res.statusCode == 200){

      setState(() {

        loading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => productAll.add(products));

        //products = json.decode(res.body);
        //recentProducts = json.decode(res.body);
        /*jsonData.forEach(([product, i]) {
          if(product['nproductMain'] != 'null'){
            products.add(product['nproductMain']);
          }
          print(product['nproductMain']);
        });*/

        print(productAll);

        return productAll;

      });

    }else{
      throw Exception('Failed load Json');
    }
    //print(searchVal);
    //print(json.decode(res.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          loading ? CircularProgressIndicator():
          AutoCompleteTextField(
            suggestions: productAll,
            decoration: InputDecoration(
              hintText: "ค้นหา"
            ),
            itemFilter: (item, query){

            },
          )
        ],
      ),
    );
  }
}
