import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:wang_shop/database_helper.dart';

import 'package:wang_shop/product_relation_type.dart';
import 'package:wang_shop/product_relation_company.dart';

import 'package:wang_shop/order.dart';
import 'package:wang_shop/search_auto_out.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class productDetailPage extends StatefulWidget {

  var product;
  productDetailPage({Key key, this.product}) : super(key: key);

  @override
  _productDetailPageState createState() => _productDetailPageState();
}

class _productDetailPageState extends State<productDetailPage> with SingleTickerProviderStateMixin {

  BlocCountOrder blocCountOrder;
  @override

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  TabController _RelationProductTab;

  //List<DropdownMenuItem<String>> units = [];
  List units = [];
  String _currentUnit;
  var unitStatus;

  var imgList = [];

  TextEditingController valAmount = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductImg();
    _RelationProductTab = new TabController(length: 2, vsync: this);
  }

  getProductImg()async{

    final res = await http.get('https://wangpharma.com/API/getImgAll.php?proCodeImg=${widget.product.productCode}');

    //var defaultImg = {'src': 'http://www.wangpharma.com/cms/product/${widget.product.productPic}'};

    //imgList.add(defaultImg);

    print(imgList);
    print(res.body);
    print(imgList.length);

    if(res.statusCode == 200){

      setState(() {
        //isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => imgList.add(products));

        print(imgList);

        return imgList;

      });


    }else{
      //throw Exception('Failed load Json');
    }
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


  Widget build(BuildContext context) {

    /*imgList = [
      'http://www.wangpharma.com/cms/product/${widget.product.productPic}',
      'http://www.wangpharma.com/cms/product/${widget.product.productPic}',
      'http://www.wangpharma.com/cms/product/${widget.product.productPic}',
    ];*/

    blocCountOrder = BlocProvider.of(context);

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
        //title: Text(widget.product.productName.toString()),
        title: Text("รายละเอียดสินค้า"),
        actions: <Widget>[
          /*IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: (){
                //Navigator.pushReplacementNamed(context, '/Order');
              }
          )*/
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
                        initialData: blocCountOrder.countOrder,
                        stream: blocCountOrder.counterStream,
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                //height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        height: 300,
                        child: PhotoViewGallery.builder(
                          itemCount: imgList.length,
                          builder: (context, index){
                            return PhotoViewGalleryPageOptions(
                              imageProvider: NetworkImage(imgList[index]['src']),
                              minScale: PhotoViewComputedScale.contained * 0.8,
                              maxScale: PhotoViewComputedScale.covered * 2,
                            );
                          },
                          scrollPhysics: BouncingScrollPhysics(),

                          backgroundDecoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                          ),
                          loadingChild: Center(
                            child: CircularProgressIndicator(),
                          ),
                          //imageProvider: NetworkImage('http://www.wangpharma.com/cms/product/${widget.product.productPic}'),

                        ),
                    ),
                    //Image.network('http://www.wangpharma.com/cms/product/${widget.product.productPic}',fit: BoxFit.contain, width:double.infinity, height: 250,),
                    (widget.product.productProStatus == '2')
                      ? Container(
                          padding: EdgeInsets.all(2),
                          color: Colors.red,
                          child: Text("Promotion",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                      : Text(''),
                    Text("รหัสสินค้า : ${widget.product.productCode}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text("ชื่อไทย : ${widget.product.productName}",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold
                      ),
                    ),

                    Text("Barcode : ${widget.product.productBarcode}",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold
                      ),
                    ),

                    Text("ชื่ออังกฤษ : ${widget.product.productNameENG}",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.blue
                      ),
                    ),
                    Text("รายละเอียด : ${widget.product.productDetail}",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.blueGrey
                      ),
                    ),
                    Text("สรรพคุณ : ${widget.product.productProperties}",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.deepPurple
                      ),
                    ),
                    Text("วิธีใช้ : ${widget.product.productHowTo}",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.teal
                      ),
                    ),
                    Divider(
                      color: Colors.deepOrange,
                      thickness: 2,
                    ),
                    /*(widget.product.productProStatus == '2')
                      ? Text('สั่งขั้นต่ำรายการโปร ${widget.product.productProLimit} : ${widget.product.productUnit1}',
                          style: TextStyle(color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold))
                      : Text(''),
                    Divider(
                      color: Colors.deepOrange,
                      thickness: 2,
                    ),
                    Container(
                      color: Colors.white,
                      //padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Row(
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              child: Expanded(
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                  controller: valAmount,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "จำนวน",
                                    contentPadding: EdgeInsets.all(4),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (val){
                                    if(val.isEmpty){
                                      return 'กรุณากรอกข้อมูล';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                          ),
                          Container(
                            child: Expanded(
                              child: DropdownButton(
                                isExpanded: true,
                                hint: Text("เลือกหน่วยสินค้า",style: TextStyle(fontSize: 18)),
                                items: units.map((dropDownStringItem){
                                  return DropdownMenuItem<String>(
                                    value: dropDownStringItem,
                                    child: Container(
                                      //color: Colors.white,
                                      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                                      child: Text(dropDownStringItem, style: TextStyle(fontSize: 18)),
                                    ),
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
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.deepOrange,
                      thickness: 2,
                    ),*/
                    /*MaterialButton(
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
                    ),*/
                  ],
                ),
              ),
              /*Padding(
                padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                child: Container(
                  color: Colors.blue,
                  child: Text('/// สินค้าหมวดเดียวกัน ///', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),),
                )
              ),
              Container(
                height: MediaQuery.of(context).size.height+1000,
                child: ProductRelationTypePage(product: widget.product,),
              ),*/
              Container(
                decoration: BoxDecoration(color: Colors.blueAccent),
                child: TabBar(
                  controller: _RelationProductTab,
                  tabs: <Widget>[
                    Tab(
                      child: Text('สินค้าหมวดเดียวกัน', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                    ),
                    Tab(
                      child: Text('สินค้าผู้ผลิตเดียวกัน', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                    ),
                  ],
                )
              ),
              Container(
                height: MediaQuery.of(context).size.height+1000,
                child: TabBarView(
                  controller: _RelationProductTab,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height+1000,
                      child: ProductRelationTypePage(product: widget.product,),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height+1000,
                      child: ProductRelationCompanyPage(product: widget.product,),
                    ),
                  ],
                ),
              )
            ])
          )
        ],
      ),
      /*bottomNavigationBar: MaterialButton(
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
      ),*/
      bottomNavigationBar: Container(
        height: 130,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: (widget.product.productProStatus == '2')
                  ? Text('สั่งขั้นต่ำรายการโปร ${widget.product.productProLimit} : ${widget.product.productUnit1}',
                  style: TextStyle(color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold))
                  : Text(''),
            ),
            Container(
              color: Colors.white,
              //padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Expanded(
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                        controller: valAmount,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "จำนวน",
                          contentPadding: EdgeInsets.all(4),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val){
                          if(val.isEmpty){
                            return 'กรุณากรอกข้อมูล';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Container(
                    child: Expanded(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Text("เลือกหน่วยสินค้า",style: TextStyle(fontSize: 18)),
                        items: units.map((dropDownStringItem){
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Container(
                              //color: Colors.white,
                              padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                              child: Text(dropDownStringItem, style: TextStyle(fontSize: 18)),
                            ),
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
                  ),
                ],
              ),
            ),
            Container(
              child: MaterialButton(
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
              ),
            )
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

    var proLimit;

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
      if(widget.product.productProStatus == '2'){
        valAmount.text = widget.product.productProLimit;
      }else{
        valAmount.text = '1';
      }

    }

    if(widget.product.productProLimit.toString() != ""){

      if(int.parse(widget.product.productProLimit) > 0){
        proLimit = int.parse(widget.product.productProLimit);
      }

    }else{
      proLimit = 1;
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
      'proStatus': widget.product.productProStatus,
      'proLimit': proLimit,
    };

    var checkOrderUnit = await databaseHelper.getOrderCheck(order['code'], order['unit']);

    if(checkOrderUnit.isEmpty){

      //print(order);
      await databaseHelper.saveOrder(order);

      Navigator.pop(context);
      showToastAddFast();
      blocCountOrder.getOrderCount();
      //showOverlay();

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
      blocCountOrder.getOrderCount();
      //showOverlay();

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

