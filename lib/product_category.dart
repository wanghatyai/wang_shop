import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/database_helper.dart';

import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/product_pro.dart';
import 'package:wang_shop/order.dart';
import 'package:wang_shop/product_detail.dart';
import 'package:wang_shop/product_category_detail.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class ProductCategoryPage extends StatefulWidget {
  @override
  _ProductCategoryPageState createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> {

  BlocCountOrder? blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List categoryAll = [];
  List categoryNameAll = [];
  List categoryCodeAll = [];


  var loading = false;

  var userName;

  getCategory() async{

    var resUser = await databaseHelper.getList();
    userName = resUser[0]['name'];

    final res = await http.get(Uri.https('wangpharma.com', '/API/product.php', {'act': 'Cat'}));

    if(res.statusCode == 200){

      setState(() {

        var jsonDataCat = json.decode(res.body);

        jsonDataCat.forEach((category) {
          categoryAll.add(category);
          categoryNameAll.add(category['name']);

          categoryCodeAll.add(category['code']);
        });

        print(categoryCodeAll);

      });

      return categoryAll;

    }else{
      throw Exception('Failed load Json');
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategory();

  }

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("หมวดสินค้า"),
        actions: <Widget>[
          IconButton(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              icon: Stack(
                children: <Widget>[
                  Icon(Icons.shopping_cart, size: 40,),
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: StreamBuilder(
                        initialData: blocCountOrder!.countOrder,
                        stream: blocCountOrder!.counterStream,
                        builder: (BuildContext context, snapshot) => Text(
                          '${snapshot.data}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
              })
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          children: <Widget>[

            loading ? Center(
              child: CircularProgressIndicator(),
            ) :
            Expanded(
              child: ListView.builder(
                itemCount: categoryAll.length,
                itemBuilder: (context, i){
                  final a = categoryAll[i];
                  return Card(
                    elevation: 8.0,
                    margin: EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCategoryDetailPage(catValue: a['code'], catName: a['name'])));
                      },
                      //leading: Image.network('http://www.wangpharma.com/cms/product/${a.productPic}', fit: BoxFit.cover, width: 70, height: 70),
                      title: Text('${a['name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                          icon: Icon(Icons.view_list, color: Colors.deepOrange, size: 40,),
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCategoryDetailPage(catValue: a['code'], catName: a['name'],)));
                          }
                      ),
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
