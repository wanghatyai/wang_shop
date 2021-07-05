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

class ProductRelationTypePage extends StatefulWidget {

  var product;
  ProductRelationTypePage({Key? key, this.product}) : super(key: key);

  @override
  _ProductRelationTypePageState createState() => _ProductRelationTypePageState();
}

class _ProductRelationTypePageState extends State<ProductRelationTypePage> {

  BlocCountOrder? blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List <Product>productRelationType = [];
  bool isLoading = true;

  var gridValForDevice = 2;

  getProductRelationType() async{

    final res = await http.get(Uri.https('wangpharma.com', '/API/product.php', {'ptype': widget.product.productCategory, 'act':'Rtype'}));

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((productR) => productRelationType.add(Product.fromJson(productR)));

        print(productRelationType);

      });

      return productRelationType;

    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductRelationType();
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
        timeInSecForIosWeb: 3
    );
  }

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    print(shortestSide);
    if(shortestSide > 600.0){
      gridValForDevice = 4;
    }

    return Scaffold(
      body: isLoading ? CircularProgressIndicator()
          :GridView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        //controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridValForDevice),
        itemBuilder: (context, int index){
          return InkWell(
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => productDetailPage(product: productRelationType[index])));
            },
            child: Card(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          Image.network('https://www.wangpharma.com/cms/product/${productRelationType[index].productPic}', fit: BoxFit.cover, width: 200,),
                          (productRelationType[index].productProStatus == '2')
                              ? Container(
                                  padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                                  width: 35,
                                  height: 25,
                                  color: Colors.red,
                                  child: Text('Pro', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),),)
                              : Container(
                                  padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                                  width: 30,
                                  height: 20,)
                        ],
                      )
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${productRelationType[index].productName}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    Text('${productRelationType[index].productNameENG}', style: TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                                  ],
                                )
                              ),
                              (productRelationType[index].productSize != "ไม่มี")
                              ? Expanded(
                                flex: 1,
                                child: IconButton(
                                    icon: Icon(Icons.add_circle, color: Colors.deepOrange, size: 35,),
                                    onPressed: (){
                                      addToOrderFast(productRelationType[index]);
                                    }
                                ),
                              )
                              : Expanded(
                                flex: 1,
                                child: IconButton(
                                    icon: Icon(Icons.close, color: Colors.red, size: 35,),
                                    onPressed: (){
                                      //addToOrderFast(productTop[index]);
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
        itemCount: productRelationType != null ? productRelationType.length : 0,
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

    print(order);

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
