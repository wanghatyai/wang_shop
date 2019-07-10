import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/database_helper.dart';
import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/product_detail.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class ProductRecomPage extends StatefulWidget {
  @override
  _ProductRecomPageState createState() => _ProductRecomPageState();
}

class _ProductRecomPageState extends State<ProductRecomPage> {

  BlocCountOrder blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  ScrollController _scrollController = new ScrollController();

  //Product product;
  List <Product>productAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "RM";

  //var product;

  getProduct() async{

    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=$perPage&act=$act');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => productAll.add(Product.fromJson(products)));
        perPage = productAll.length;

        print(productAll);
        print(productAll.length);

        return productAll;

      });

    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProduct();

    _scrollController.addListener((){
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        getProduct();
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
      body: isLoading ? CircularProgressIndicator()
          :ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, int index){
          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(10, 1, 10, 1),
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => productDetailPage(product: productAll[index])));
            },
            leading: Image.network('http://www.wangpharma.com/cms/product/${productAll[index].productPic}', fit: BoxFit.cover, width: 70, height: 70),
            title: Text('${productAll[index].productName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${productAll[index].productCode}'),
                Text('${productAll[index].productNameENG}', style: TextStyle(color: Colors.blue), overflow: TextOverflow.ellipsis),
                productAll[index].productProLimit != "" ?
                Text('สั่งขั้นต่ำ ${productAll[index].productProLimit} : ${productAll[index].productUnit1}', style: TextStyle(color: Colors.red)) : Text(''),
              ],
            ),
            trailing: IconButton(
                icon: Icon(Icons.add_to_photos, color: Colors.teal, size: 40,),
                onPressed: (){
                  addToOrderFast(productAll[index]);
                }
            ),
          );
        },
        itemCount: productAll != null ? productAll.length : 0,
      ),


    );
  }

  addToOrderFast(productFast) async{

    var unit1;
    var unit2;
    var unit3;

    int amount;

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

    if(productFast.productProLimit != ""){

      if(int.parse(productFast.productProLimit) > 1){
        amount = int.parse(productFast.productProLimit);
      }

    }else{
      amount = 1;
    }

    //print('99999-${productFast.productPriceA}');

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
      'amount': amount,
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

      var sumAmount = checkOrderUnit[0]['amount'] + amount;
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
