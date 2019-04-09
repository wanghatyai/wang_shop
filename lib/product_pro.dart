import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/database_helper.dart';
import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/product_detail.dart';

import 'package:fluttertoast/fluttertoast.dart';

class ProductProPage extends StatefulWidget {
  @override
  _ProductProPageState createState() => _ProductProPageState();
}

class _ProductProPageState extends State<ProductProPage> {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  ScrollController _scrollController = new ScrollController();

  //Product product;
  List <Product>productAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Pro";

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

  showOverlay() async{

    var countOrder = await databaseHelper.countOrder();
    print(countOrder[0]['countOrderAll']);

    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 25,
          right: 30,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.red,
            child: Text("${countOrder[0]['countOrderAll']}",style: TextStyle(color: Colors.white)),
          ),
        )
    );

    overlayState.insert(overlayEntry);
    //await Future.delayed(Duration(seconds: 2));
    //overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: isLoading ? CircularProgressIndicator()
            :ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, int index){
                        return ListTile(
                          contentPadding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => productDetailPage(product: productAll[index])));
                          },
                          leading: Image.network('http://www.wangpharma.com/cms/product/${productAll[index].productPic}', fit: BoxFit.cover, width: 70, height: 70),
                          title: Text('${productAll[index].productCode}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${productAll[index].productName}'),
                              Text('${productAll[index].productNameENG}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.shopping_basket, color: Colors.teal, size: 30,),
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
      'code': productFast.productCode.toString(),
      'name': productFast.productName.toString(),
      'pic': productFast.productPic.toString(),
      'unit': productFast.productUnit1.toString(),
      'unit1': unit1,
      'unit2': unit2,
      'unit3': unit3,
      'amount': 1,
    };

    var checkOrderUnit = await databaseHelper.getOrderCheck(order['code'], order['unit']);

    //print(checkOrderUnit.isEmpty);

    if(checkOrderUnit.isEmpty){

      //print(order);
      await databaseHelper.saveOrder(order);

      showToastAddFast();
      showOverlay();

    }else{

      var sumAmount = checkOrderUnit[0]['amount'] + 1;
      Map order = {
        'id': checkOrderUnit[0]['id'],
        'unit': checkOrderUnit[0]['unit'],
        'amount': sumAmount,
      };

      await databaseHelper.updateOrder(order);

      showToastAddFast();
      showOverlay();

    }

    //Navigator.pushReplacementNamed(context, '/Home');

  }

}