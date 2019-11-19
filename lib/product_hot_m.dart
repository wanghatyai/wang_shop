import 'package:flutter/cupertino.dart';
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

class ProductHotMonthPage extends StatefulWidget {
  @override
  _ProductHotMonthPageState createState() => _ProductHotMonthPageState();
}

class _ProductHotMonthPageState extends State<ProductHotMonthPage> {

  BlocCountOrder blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  //Product product;
  List <Product>productTop = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Top";

  getProductTop() async{

    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=$perPage&act=$act');

    if(res.statusCode == 200){

      if (mounted) {
        setState(() {
          isLoading = false;

          var jsonData = json.decode(res.body);

          jsonData.forEach((products) =>
              productTop.add(Product.fromJson(products)));
          perPage = productTop.length;

          print(productTop);
          print(productTop.length);

          return productTop;
        });
      }

    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductTop();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
          :GridView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        //controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, int index){
          return InkWell(
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => productDetailPage(product: productTop[index])));
            },
            child: Card(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Image.network('https://www.wangpharma.com/cms/product/${productTop[index].productPic}', fit: BoxFit.fill, width: 200,),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      //alignment: Alignment.topLeft,
                      child: Column(
                        children: <Widget>[
                          //Text('${productTop[index].productCode}', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Text('${productTop[index].productName}', style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                    icon: Icon(Icons.add_to_photos, color: Colors.teal, size: 30,),
                                    onPressed: (){
                                      addToOrderFast(productTop[index]);
                                    }
                                ),
                              )
                            ],
                          )

                        ],
                      ),
                    ),
                  ],
                )
            ),
          );
        },
        itemCount: productTop != null ? productTop.length : 0,
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

      if(int.parse(productFast.productProLimit) > 0){
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

    print(order);

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
