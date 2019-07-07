import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/database_helper.dart';

import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/product_pro.dart';
import 'package:wang_shop/order.dart';
import 'package:wang_shop/product_detail.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class ProductCategoryDetailPage extends StatefulWidget {

  final String catValue;

  ProductCategoryDetailPage({Key key, this.catValue}) : super (key: key);

  @override
  _ProductCategoryDetailPageState createState() => _ProductCategoryDetailPageState();
}

class _ProductCategoryDetailPageState extends State<ProductCategoryDetailPage> {

  BlocCountOrder blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List<Product> _product = [];

  ScrollController _scrollController = new ScrollController();

  int perPage = 30;

  var loading = true;

  var userName;

  getCategoryDetail() async{

    var resUser = await databaseHelper.getList();
    userName = resUser[0]['name'];

    //_product.clear();

    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=$perPage&SearchVal=${widget.catValue}&act=SearchCat');

    if(res.statusCode == 200){

      setState(() {

        loading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => _product.add(Product.fromJson(products)));
        perPage = _product.length;

        print(_product);
        return _product;

      });

    }else{
      throw Exception('Failed load Json');
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategoryDetail();

    _scrollController.addListener((){
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        getCategoryDetail();
      }
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }


  showToastAddFast(){
    Fluttertoast.showToast(
        msg: "เพิ่มรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3
    );
  }

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("${userName}"),
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
                        initialData: blocCountOrder.countOrder,
                        stream: blocCountOrder.counterStream,
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
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: Column(
          children: <Widget>[

            loading ? Center(
              child: CircularProgressIndicator(),
            ) :
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _product.length,
                itemBuilder: (context, i){
                  final a = _product[i];
                  return ListTile(
                    contentPadding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                    onTap: (){

                    },
                    leading: Image.network('http://www.wangpharma.com/cms/product/${a.productPic}', fit: BoxFit.cover, width: 70, height: 70),
                    title: Text('${a.productName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${a.productCode}'),
                        Text('${a.productNameENG}', style: TextStyle(color: Colors.blue), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.add_to_photos, color: Colors.teal, size: 40,),
                        onPressed: (){
                          addToOrderFast(a);
                        }
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

  addToOrderFast(productFast) async{

    var unit1;
    var unit2;
    var unit3;

    if(productFast.productUnit1.toString() != "null"){
      unit1 = productFast.productUnit1.toString();
    }else{
      unit1 = 'NULL';
    }
    if(productFast.productUnit2.toString() != "null"){
      unit2 = productFast.productUnit2.toString();
    }else{
      unit2 = 'NULL';
    }
    if(productFast.productUnit3.toString() != "null"){
      unit3 = productFast.productUnit3.toString();
    }else{
      unit3 = 'NULL';
    }

    Map order = {
      'productID': productFast.productId.toString(),
      'code': productFast.productCode.toString(),
      'name': productFast.productName.toString(),
      'pic': productFast.productPic.toString(),
      'unit': productFast.productUnit1.toString(),
      'unitStatus': 1,
      'unit1': unit1,
      'unitQty1': productFast.productUnitQty1,
      'unit2': unit2,
      'unitQty2': productFast.productUnitQty2,
      'unit3': unit3,
      'unitQty3': productFast.productUnitQty3,
      'priceA': productFast.productPriceA,
      'priceB': productFast.productPriceB,
      'priceC': productFast.productPriceC,
      'amount': 1,
      'proStatus': productFast.productProStatus,
    };

    var checkOrderUnit = await databaseHelper.getOrderCheck(order['code'], order['unit']);

    //print(checkOrderUnit.isEmpty);

    if(checkOrderUnit.isEmpty){

      //print(order);
      await databaseHelper.saveOrder(order);

      showToastAddFast();

      //add notify order
      blocCountOrder.getOrderCount();

    }else{

      var sumAmount = checkOrderUnit[0]['amount'] + 1;
      Map order = {
        'id': checkOrderUnit[0]['id'],
        'unit': checkOrderUnit[0]['unit'],
        'unitStatus': 1,
        'amount': sumAmount,
      };

      await databaseHelper.updateOrder(order);

      showToastAddFast();

      //add notify order
      blocCountOrder.getOrderCount();

    }

    //Navigator.pushReplacementNamed(context, '/Home');

  }
}
