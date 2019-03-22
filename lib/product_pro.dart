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
  List productAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Pro";

  var product;

  getProduct() async{

    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=$perPage&act=$act');

    //print('http://wangpharma.com/API/product.php?PerPage=$perPage&act=$act');

    if(res.statusCode == 200){
      //var jsonRes = json.decode(res.body);
      //print(jsonRes);

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        /*for(var u in jsonData){
          Product product = Product(u['id'], u['nproductMain'], u['pcode'], u['nproductENG'], u['pic']);

          //print(u['nproductMain']);

          productAll.add(product);

        }*/

        jsonData.forEach((products) => productAll.add(products));
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
          right: 5,
          child: CircleAvatar(
            radius: 10,
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
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => productDetailPage(product: productAll[index])));
                          },
                          leading: Image.network('http://www.wangpharma.com/cms/product/${productAll[index]['pic']}',width: 70, height: 70,),
                          title: Text('${productAll[index]['nproductMain']}'),
                          subtitle: Text('${productAll[index]['nproductENG']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.shopping_basket, color: Colors.teal),
                            onPressed: (){
                              addToOrderFast(productAll[index]);
                              showOverlay();
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

    if(productFast['unit1'].toString() != "null"){
      unit1 = productFast['unit1'].toString();
    }else{
      unit1 = 'NULL';
    }
    if(productFast['unit2'].toString() != "null"){
      unit2 = productFast['unit2'].toString();
    }else{
      unit2 = 'NULL';
    }
    if(productFast['unit3'].toString() != "null"){
      unit3 = productFast['unit3'].toString();
    }else{
      unit3 = 'NULL';
    }

    Map order = {
      'code': productFast['pcode'].toString(),
      'name': productFast['nproductMain'].toString(),
      'pic': productFast['pic'].toString(),
      'unit': productFast['unit1'].toString(),
      'unit1': unit1,
      'unit2': unit2,
      'unit3': unit3,
      'amount': 1,
    };

    showToastAddFast();

      print(order);
    await databaseHelper.saveOrder(order);

    //Navigator.pushReplacementNamed(context, '/Home');

  }

}