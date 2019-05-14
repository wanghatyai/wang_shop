import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/database_helper.dart';

import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/product_pro.dart';
import 'package:wang_shop/product_detail.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class searchAutoOutPage extends StatefulWidget {
  @override
  _searchAutoOutPageState createState() => _searchAutoOutPageState();
}

class _searchAutoOutPageState extends State<searchAutoOutPage> {

  BlocCountOrder blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List<Product> _product = [];
  List<Product> _search = [];

  var loading = false;
  String barcode;

  scanBarcode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState((){
        this.barcode = barcode;
        searchProduct(this.barcode);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _showAlertBarcode();
        print('Camera permission was denied');
      } else {
        print('Unknow Error $e');
      }
    } on FormatException {
      print('User returned using the "back"-button before scanning anything.');
    } catch (e) {
      print('Unknown error.');
    }
  }

  void _showAlertBarcode() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('คุณไม่เปิดอนุญาตใช้กล้อง'),
        );
      },
    );
  }

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
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: Column(
         children: <Widget>[
           Container(
             //padding: EdgeInsets.all(10),
             child: ListTile(
               leading: IconButton(
                   icon: Icon(Icons.center_focus_strong, color: Colors.red, size: 30,),
                   onPressed: (){
                     scanBarcode();
                   }
               ),
               title: TextField(
                 controller: controller,
                 onChanged: onSearch,
                 decoration: InputDecoration(
                   hintText: "ค้นหา",
                 ),
               ),
               trailing: IconButton(
                   icon: Icon(Icons.cancel),
                   onPressed: (){
                     controller.clear();
                   }
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
                 return ListTile(
                   contentPadding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                   onTap: (){

                   },
                   leading: Image.network('http://www.wangpharma.com/cms/product/${a.productPic}', fit: BoxFit.cover, width: 70, height: 70),
                   title: Text('${a.productCode}', style: TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: <Widget>[
                       Text('${a.productName}'),
                       Text('${a.productNameENG}', style: TextStyle(color: Colors.blue),),
                     ],
                   ),
                   trailing: IconButton(
                       icon: Icon(Icons.shopping_basket, color: Colors.teal, size: 30,),
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
