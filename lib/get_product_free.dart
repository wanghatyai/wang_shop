import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wang_shop/product_model.dart';

import 'package:wang_shop/database_helper.dart';

class getProductFreePage extends StatefulWidget {

  var score;
  getProductFreePage({Key key, this.score}) : super (key: key);

  @override
  _getProductFreePageState createState() => _getProductFreePageState();
}

class _getProductFreePageState extends State<getProductFreePage> {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List <Product>productFree = [];
  var limitScore = 0;

  getProduct() async{

    final res = await http.get('https://wangpharma.com/API/product.php?Score=${widget.score}&act=Free');

    if(res.statusCode == 200){

      setState(() {
        //isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => productFree.add(Product.fromJson(products)));
        //perPage = productFree.length;

        print(productFree);
        print(productFree.length);

        return productFree;

      });


    }else{
      throw Exception('Failed load Json');
    }
  }

  showDialogLimit() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("ขออภัย"),
          content: new Text("คุณเลือกสินค้าเกินจำนวนแต้ม"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("ปิด"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showToastAddFast(){
    Fluttertoast.showToast(
        msg: "เพิ่มรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3
    );
  }

  addProductFree(productFree) async{
    print(limitScore);

    var score = int.parse(productFree.productFreePrice);


    Map orderFree = {
      'productID': productFree.productId.toString(),
      'code': productFree.productCode.toString(),
      'name': productFree.productName.toString(),
      'pic': productFree.productPic.toString(),
      'unitStatus': 1,
      'unit1': productFree.productUnit1.toString(),
      'freePrice': productFree.productFreePrice,
      'freePriceSum': productFree.productFreePrice,
      'amount': 1,
    };

    var checkOrderFree = await databaseHelper.getOrderFreeCheck(orderFree['code']);

    if((limitScore+score) > widget.score ){
      showDialogLimit();
      print('NO');
    }else{

      if(checkOrderFree.isEmpty){
        await databaseHelper.saveOrderFree(orderFree);

      }else{

        var sumAmount = checkOrderFree[0]['amount'] + 1;
        var freePriceSumAll = checkOrderFree[0]['freePriceSum'] * checkOrderFree[0]['amount'];
        Map orderFree = {
          'id': checkOrderFree[0]['id'],
          'freePriceSum': freePriceSumAll,
          'amount': sumAmount,
        };

        await databaseHelper.updateOrderFree(orderFree);
      }

      limitScore = limitScore+score;
      showToastAddFast();
      print('add score');
    }
  }

  initLimitScore() async{

    var getOrderFreeSum = await databaseHelper.getSumOrderFree();

    if(getOrderFreeSum.isEmpty){
      limitScore = 0;
    }else{
      if(getOrderFreeSum[0]['freePriceSumAll'] != null){
        limitScore = getOrderFreeSum[0]['freePriceSumAll'];
      }else{
        limitScore = 0;
      }

    }
    print(limitScore);

  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getProduct();
    initLimitScore();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
              child:ListView.builder(
                //separatorBuilder: (context, index) => Divider(
                //color: Colors.black,
                //),
                itemBuilder: (context, int index){
                  return ListTile(
                    onTap: (){
                      setState(() {
                        addProductFree(productFree[index]);
                      });
                    },
                    contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                    leading: Image.network('https://www.wangpharma.com/cms/product/${productFree[index].productPic}',fit: BoxFit.cover, width: 70, height: 70,),
                    title: Text('${productFree[index].productName}', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${productFree[index].productCode}'),
                        Text('${productFree[index].productFreePrice} แต้ม : ${productFree[index].productUnit1}',
                          style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    trailing: Icon(Icons.add_circle, color: Colors.teal, size: 30),
                  );
                },
                itemCount: productFree != null ? productFree.length : 0,
              )
         );
  }
}
