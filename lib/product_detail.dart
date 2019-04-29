import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:wang_shop/database_helper.dart';

import 'package:fluttertoast/fluttertoast.dart';

class productDetailPage extends StatefulWidget {

  var product;
  productDetailPage({Key key, this.product}) : super(key: key);

  @override
  _productDetailPageState createState() => _productDetailPageState();
}

class _productDetailPageState extends State<productDetailPage> {
  @override

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  //List<DropdownMenuItem<String>> units = [];
  List units = [];
  String _currentUnit;
  var unitStatus;

  TextEditingController valAmount = TextEditingController();

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



  Widget build(BuildContext context) {

    units = [];

    if(widget.product.productUnit1.toString() != "null"){
      units.add(widget.product.productUnit1.toString());
      //setState(() {
      //_currentUnit = widget.product['unit1'].toString();
      //});
    }
    if(widget.product.productUnit2.toString() != "null"){
      units.add(widget.product.productUnit2.toString());
    }
    if(widget.product.productUnit3.toString() != "null"){
      units.add(widget.product.productUnit3.toString());
    }

    if(_currentUnit == null){
      _currentUnit = widget.product.productUnit1.toString();
    }

    //loadUnits();
    //print(widget.product['unit3'].toString());
    //print(_currentUnit);
    //print(_units);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.product.productName.toString()),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: (){
                //Navigator.pushReplacementNamed(context, '/Order');
              }
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.network('http://www.wangpharma.com/cms/product/${widget.product.productPic}',fit: BoxFit.contain, width:double.infinity, height: 250,),
                  Text("รหัสสินค้า : ${widget.product.productCode}",
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                  Text("barcode : ${widget.product.productBarcode}",
                    style: TextStyle(
                        fontSize: 17
                    ),
                  ),

                  Text("ชื่อไทย : ${widget.product.productName}",
                    style: TextStyle(
                        fontSize: 17
                    ),
                  ),

                  Text("ชื่ออังกฤษ : ${widget.product.productNameENG}",
                    style: TextStyle(
                        fontSize: 17
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: valAmount,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "จำนวน",
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String val){
                            if(val.isEmpty) return 'กรุณากรอกข้อมูล';
                          },
                        ),
                      ),
                      Expanded(
                        child: DropdownButton(
                          hint: Text("เลือกหน่วยสินค้า",style: TextStyle(fontSize: 18)),
                          items: units.map((dropDownStringItem){
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem, style: TextStyle(fontSize: 18)),
                            );
                          }).toList(),
                          onChanged: (newValueSelected){
                            var tempIndex = units.indexOf(newValueSelected)+1;
                            _onDropDownItemSelected(newValueSelected, tempIndex);
                            print(this._currentUnit);
                            print(tempIndex);

                          },
                          value: _currentUnit,

                        ),

                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                  ),
                  MaterialButton(
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    minWidth: double.infinity,
                    height: 50,
                    child: Text(
                      "หยิบใส่ตะกร้า",
                      style: new TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    //onPressed: (){Navigator.pushReplacementNamed(context, '/Home');},
                    onPressed: () {
                      addToOrder();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  _onDropDownItemSelected(newValueSelected, newIndexSelected){
    setState(() {
      _currentUnit = newValueSelected;
      unitStatus = newIndexSelected;
      //print('select--${units}');
    });
  }

  addToOrder() async{

    var unit1;
    var unit2;
    var unit3;
    //var unitStatus;

    if(widget.product.productUnit1.toString() != "null"){
      unit1 = widget.product.productUnit1.toString();
    }else{
      unit1 = 'NULL';
    }
    if(widget.product.productUnit2.toString() != "null"){
      unit2 = widget.product.productUnit2.toString();
    }else{
      unit2 = 'NULL';
    }
    if(widget.product.productUnit3.toString() != "null"){
      unit3 = widget.product.productUnit3.toString();
    }else{
      unit3 = 'NULL';
    }

    if(unitStatus == null){
      unitStatus = 1;
    }

    if(valAmount.text == ''){
      valAmount.text = '1';
    }

    /*if(widget.product.productUnit1.toString() == _currentUnit){
      unitStatus = 1;
    }
    if(widget.product.productUnit2.toString() == _currentUnit){
      unitStatus = 2;
    }
    if(widget.product.productUnit3.toString() == _currentUnit){
      unitStatus = 3;
    }*/

    Map order = {
      'productID': widget.product.productId.toString(),
      'code': widget.product.productCode.toString(),
      'name': widget.product.productName.toString(),
      'pic': widget.product.productPic.toString(),
      'unit': _currentUnit,
      'unitStatus': unitStatus,
      'unit1': unit1,
      'unitQty1': widget.product.productUnitQty1,
      'unit2': unit2,
      'unitQty2': widget.product.productUnitQty2,
      'unit3': unit3,
      'unitQty3': widget.product.productUnitQty3,
      'priceA': widget.product.productPriceA,
      'priceB': widget.product.productPriceB,
      'priceC': widget.product.productPriceC,
      'amount': valAmount.text,
    };

    var checkOrderUnit = await databaseHelper.getOrderCheck(order['code'], order['unit']);

    if(checkOrderUnit.isEmpty){

      //print(order);
      await databaseHelper.saveOrder(order);

      Navigator.pop(context);
      showToastAddFast();
      showOverlay();

    }else{

      var sumAmount = checkOrderUnit[0]['amount'] + int.parse(valAmount.text);
      Map order = {
        'id': checkOrderUnit[0]['id'],
        'unit': checkOrderUnit[0]['unit'],
        'unitStatus': unitStatus,
        'amount': sumAmount,
      };

      await databaseHelper.updateOrder(order);

      Navigator.pop(context);
      showToastAddFast();
      showOverlay();

    }

    //await databaseHelper.saveOrder(order);

    //print(order);
    //Navigator.pushReplacementNamed(context, '/Home');
    //Navigator.pop(context);
    //showToastAddFast();
    //showOverlay();
  }

/*_defaultDropDownItemSelected(newValueSelected){

    setState(() {
      if(_currentUnit != ""){
        _currentUnit = newValueSelected;
      }else{
        _currentUnit = widget.product['unit1'].toString();
      }
    });
      //print('select--${units}');

  }*/
}

