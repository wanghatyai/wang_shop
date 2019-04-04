import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/product_model.dart';

class searchAutoOutPage extends StatefulWidget {
  @override
  _searchAutoOutPageState createState() => _searchAutoOutPageState();
}

class _searchAutoOutPageState extends State<searchAutoOutPage> {

  List<Product> _product = [];
  List<Product> _search = [];

  var loading = false;

  searchProduct(searchVal) async{

    setState(() {
      loading = true;
    });
    _product.clear();

    //productAll = [];

    final res = await http.get('http://wangpharma.com/API/product.php?SearchVal=$searchVal&act=Search');

    if(res.statusCode == 200){

      setState(() {

        loading = false;

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

  TextEditingController controller = new TextEditingController();

  onSearch(String text) async{
    _search.clear();
    if(text.isEmpty){
      setState(() {});
      return;
    }

    searchProduct(text);
    
    _product.forEach((f){
      if(f.productName.contains(text)) _search.add(f);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: Column(
         children: <Widget>[
           Container(
             padding: EdgeInsets.all(10),
             child: TextField(
               controller: controller,
               onChanged: onSearch,
               decoration: InputDecoration(
                   hintText: "ค้นหา",
               ),
             ),
           ),
           loading ? Center(
             child: CircularProgressIndicator(),
           ) :
           Expanded(
             child: ListView.builder(
               itemCount: _product.length,
               itemBuilder: (context, i){
                 final a = _product[i];
                 return Container(
                   padding: EdgeInsets.all(10),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: <Widget>[
                       Text(a.productName),
                       SizedBox(height: 4),
                     ],
                   ),
                 );
               },
             ),
           ),
         ],
        ),
      ),
    );
  }
}
