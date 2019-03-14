import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:wang_shop/database_helper.dart';

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

  TextEditingController valAmount = TextEditingController();

  /*loadUnits(){
    units = [];
    //_currentUnit = widget.product['unit1'].toString();

    if(widget.product['unit1'].toString() != "null"){

      units.add(DropdownMenuItem(
        child: Text(widget.product['unit1'].toString()),
        value: widget.product['unit1'].toString(),
      ));
    }
    if(widget.product['unit2'].toString() != "null"){
      units.add(DropdownMenuItem(
        child: Text(widget.product['unit2'].toString()),
        value: widget.product['unit2'].toString(),
      ));
    }
    if(widget.product['unit3'].toString() != "null"){
      units.add(DropdownMenuItem(
        child: Text(widget.product['unit3'].toString()),
        value: widget.product['unit3'].toString(),
      ));
    }
  }*/



  Widget build(BuildContext context) {

    units = [];

    if(widget.product['unit1'].toString() != "null"){
      units.add(widget.product['unit1'].toString());
      //setState(() {
      //_currentUnit = widget.product['unit1'].toString();
      //});
    }
    if(widget.product['unit2'].toString() != "null"){
      units.add(widget.product['unit2'].toString());
    }
    if(widget.product['unit3'].toString() != "null"){
      units.add(widget.product['unit3'].toString());
    }


    //loadUnits();
    //print(widget.product['unit3'].toString());
    //print(_currentUnit);
    //print(_units);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.product['nproductMain'].toString()),
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
                  Image.network('http://www.wangpharma.com/cms/product/${widget.product['pic']}',fit: BoxFit.contain, width:double.infinity, height: 250,),
                  Text("รหัสสินค้า : ${widget.product['pcode']}",
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),

                  Text("ชื่อไทย : ${widget.product['nproductMain']}",
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),

                  Text("ชื่ออังกฤษ : ${widget.product['nproductENG']}",
                    style: TextStyle(
                        fontSize: 18
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
                            _onDropDownItemSelected(newValueSelected);
                            print(this._currentUnit);

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

  _onDropDownItemSelected(newValueSelected){
    setState(() {
      _currentUnit = newValueSelected;
      //print('select--${units}');
    });
  }

  addToOrder() async{
    Map order = {
      'code': widget.product['pcode'].toString(),
      'name': widget.product['nproductMain'].toString(),
      'pic': widget.product['pic'].toString(),
      'unit': _currentUnit,
      'amount': valAmount.text,
    };

    await databaseHelper.saveOrder(order);

    print(order);
    Navigator.pushReplacementNamed(context, '/Home');

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

