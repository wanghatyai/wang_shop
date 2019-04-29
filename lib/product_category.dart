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

class ProductCategoryPage extends StatefulWidget {
  @override
  _ProductCategoryPageState createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List<Product> _product = [];
  List<Product> _search = [];
  List categoryAll = [];
  List categoryNameAll = [];
  List categoryCodeAll = [];

  String _currentCategory;

  var loading = false;

  var userName;

  getCategory() async{

    var resUser = await databaseHelper.getList();
    userName = resUser[0]['name'];

    final res = await http.get('http://wangpharma.com/API/product.php?act=Cat');

    if(res.statusCode == 200){

      setState(() {

        var jsonDataCat = json.decode(res.body);

        jsonDataCat.forEach((category) {
          categoryAll.add(category);
          categoryNameAll.add(category['name']);

          categoryCodeAll.add(category['code']);
        });

        print(categoryCodeAll);
        return categoryAll;

      });

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

  searchProduct(searchVal) async{

    setState(() {
      loading = true;
    });
    _product.clear();

    //productAll = [];

    final res = await http.get('http://wangpharma.com/API/product.php?SearchVal=$searchVal&act=SearchCat');

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
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("${userName}"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.shopping_cart, size: 30,),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
              })
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: DropdownButton(
                isExpanded: true,
                hint: Text("เลือกหมวดสินค้า",style: TextStyle(fontSize: 18)),
                items: categoryNameAll.map((dropDownStringItem){
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),
                onChanged: (newValueSelected){
                  var tempIndex = categoryNameAll.indexOf(newValueSelected);
                  //_onDropDownItemSelected(newValueSelected, tempIndex);
                  //print(this._currentCategory);
                  //setState(() {
                    //_currentCategory = categoryCodeAll[tempIndex];
                  //});
                  //print(categoryCodeAll[tempIndex]);
                  onSearch(categoryCodeAll[tempIndex]);
                  //print(tempIndex);

                },
                value: _currentCategory,

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
                    title: Text('${a.productCode}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${a.productName}'),
                        Text('${a.productNameENG}'),
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
      showOverlay();

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
      showOverlay();

    }

    //Navigator.pushReplacementNamed(context, '/Home');

  }
}
