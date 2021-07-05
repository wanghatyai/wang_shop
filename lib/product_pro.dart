import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/database_helper.dart';
import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/product_detail.dart';

import 'package:wang_shop/order.dart';
import 'package:wang_shop/search_auto_out.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class ProductProPage extends StatefulWidget {

  @override
  _ProductProPageState createState() => _ProductProPageState();
}

class _ProductProPageState extends State<ProductProPage> {

  BlocCountOrder? blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  ScrollController _scrollController = new ScrollController();

  //Product product;
  List <Product>productAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Pro";

  //var product;

  getProduct() async{

    print(perPage);

    final res = await http.get(Uri.https('wangpharma.com', '/API/product.php', {'PerPage': perPage.toString(), 'act':'Pro'}));

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => productAll.add(Product.fromJson(products)));
        perPage = perPage + 30;

        print(productAll);
        print(perPage);


      });

      return productAll;


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
        timeInSecForIosWeb: 3
    );
  }

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("สินค้าโปรโมชั่น"),
          actions: <Widget>[
            IconButton(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                icon: Stack(
                  children: <Widget>[
                    Icon(Icons.search, size: 40,),
                  ],
                ),
                onPressed: (){
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => searchAutoOutPage()));
                }
            ),
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
                }
            ),
          ],
        ),
        body: isLoading ? CircularProgressIndicator()
            :ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, int index){
                        return Card(
                          elevation: 8.0,
                          margin: EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.fromLTRB(10, 1, 10, 1),
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => productDetailPage(product: productAll[index])));
                            },
                            leading: Stack(
                              children: <Widget>[
                                Image.network('https://www.wangpharma.com/cms/product/${productAll[index].productPic}', fit: BoxFit.cover, width: 70, height: 70,),
                                (productAll[index].productProStatus == '2')?
                                Container(
                                  padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                                  width: 30,
                                  height: 20,
                                  color: Colors.red,
                                  child: Text('Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                ) : Container(
                                  padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                                  width: 30,
                                  height: 20,
                                )
                              ],
                            ),
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
                            trailing: (productAll[index].productSize != "ไม่มี")
                            ? IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.deepOrange, size: 40,),
                                onPressed: (){
                                  addToOrderFast(productAll[index]);
                                }
                              )
                            : IconButton(
                                icon: Icon(Icons.close, color: Colors.red, size: 40,),
                                onPressed: (){

                                }
                              ),
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

    if(productFast.productUnit1.toString() != "null" && productFast.productUnit1.toString().isNotEmpty){
      unit1 = productFast.productUnit1.toString();
    }else{
      unit1 = 'NULL';
    }
    if(productFast.productUnit2.toString() != "null" && productFast.productUnit2.toString().isNotEmpty){
      unit2 = productFast.productUnit2.toString();
    }else{
      unit2 = 'NULL';
    }
    if(productFast.productUnit3.toString() != "null" && productFast.productUnit3.toString().isNotEmpty){
      unit3 = productFast.productUnit3.toString();
    }else{
      unit3 = 'NULL';
    }

    if(productFast.productProLimit != "" && productFast.productProStatus == '2'){

      if(int.parse(productFast.productProLimit) > 0){
        amount = int.parse(productFast.productProLimit);
      }else{
        amount = 1;
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
      'proLimit': amount,
    };

    var checkOrderUnit = await databaseHelper.getOrderCheck(order['code'], order['unit']);

    //print(checkOrderUnit.isEmpty);

    if(checkOrderUnit.isEmpty){

      //print(order);
      await databaseHelper.saveOrder(order);

      showToastAddFast();

      //add notify order
      blocCountOrder!.getOrderCount();

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
      blocCountOrder!.getOrderCount();

    }
    //Navigator.pushReplacementNamed(context, '/Home');

  }

}