import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/product_detail.dart';

import 'package:wang_shop/ship_dialog.dart';
import 'package:wang_shop/pay_dialog.dart';
import 'package:wang_shop/summary_order.dart';
import 'package:wang_shop/edit_dialog.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {

  BlocCountOrder blocCountOrder;

  @override
  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List orders = [];

  List units = [];
  String _currentUnit;
  var unitStatus;

  int selectedRadioTileShip;
  int selectedRadioTilePay;

  var sumAmount = 0.0;
  var freeLimit = 0.0;

  //Product productTop;
  List <Product>productTop = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Top";

  getOrderAll() async{

    var unitQty1;
    var unitQty2;
    var unitQty3;

    sumAmount = 0.0;

    var res = await databaseHelper.getOrder();
    var resUser = await databaseHelper.getList();
    print(res);

    var userCredit;

    userCredit = resUser[0]['credit'];

    var priceCredit;

    res.forEach((order) {

      unitQty1 = (order['unitQty1']/order['unitQty1']);
      unitQty2 = (order['unitQty1']/order['unitQty2']);
      unitQty3 = (order['unitQty1']/order['unitQty3']);

      if(order['proStatus'] == 2){
        priceCredit = order['priceA'];
      }else {
        if (userCredit == 'A') {
          priceCredit = order['priceA'];
        } else if (userCredit == 'B') {
          priceCredit = order['priceB'];
        } else {
          priceCredit = order['priceC'];
        }
      }


      if(order['unitStatus'] == 1){
        sumAmount = sumAmount + ((priceCredit * unitQty1) * order['amount']);
      }

      if(order['unitStatus'] == 2){
        sumAmount = sumAmount + ((priceCredit * unitQty2) * order['amount']);

      }

      if(order['unitStatus'] == 3){
        sumAmount = sumAmount + ((priceCredit * unitQty3) * order['amount']);
      }

    });

    freeLimit = sumAmount*0.01;

    print(freeLimit);

    setState(() {
      orders = res;
    });

  }


  getProductTop() async{

    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=$perPage&act=$act');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => productTop.add(Product.fromJson(products)));
        perPage = productTop.length;

        print(productTop);
        print(productTop.length);

        return productTop;

      });

    }else{
      throw Exception('Failed load Json');
    }
  }

  void _showAlertCheckOrder() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('กรุณาเลือกรายการสินค้าอย่างน้อย 1 รายการ'),
        );
      },
    );
  }

  showToastRemove(){
    Fluttertoast.showToast(
        msg: "ลบรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3
    );
  }

  saveEditOrderDialog(id, unit, unitStatusVal, amount) async {
    Map order = {
      'id': id,
      'unit': unit,
      'unitStatus': unitStatusVal,
      'amount': amount,
    };
    await databaseHelper.updateOrder(order);
    getOrderAll();
  }

  editOrderDialog(order, closeDialog){

    units = [];

    //if(_currentUnit.isEmpty){
    _currentUnit = order['unit'].toString();
    unitStatus = order['unitStatus'];
    //}else{
    //_currentUnit = this._currentUnit;
    //}

    if(order['unit1'].toString() != "NULL"){
      units.add(order['unit1'].toString());
    }
    if(order['unit2'].toString() != "NULL"){
      units.add(order['unit2'].toString());
    }
    if(order['unit3'].toString() != "NULL"){
      units.add(order['unit3'].toString());
    }

    print(_currentUnit);
    print(units);

    TextEditingController editAmount = TextEditingController();

    editAmount.text = order['amount'].toString();

    return showDialog(context: context, builder: (context) {
      return EditDialogPage(units: units, orderE: order);
    }).then((e){
      getOrderAll();
    });

  }

  selectShip(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: Text('เลือกวิธีการรับสินค้า'),
        children: <Widget>[
          Divider(
            color: Colors.black,
          ),
          ShipDialogPage(),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          SimpleDialogOption(
            onPressed: (){
              selectPay();
            },
            child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.green,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                          'ตกลง',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ],
                )
            ),
          ),
        ],
      );
    });
  }

  selectPay(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: Text('เลือกวิธีชำระเงิน'),
        children: <Widget>[
          //Text('จำนวน'),
          Divider(
            color: Colors.black,
          ),
          PayDialogPage(),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          SimpleDialogOption(
            onPressed: (){

              Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryOrderPage()));
            },
            child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.green,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                          'ตกลง',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ],
                )
            ),
          ),
        ],


      );
    });
  }



  /*_onDropDownItemSelected(newValueSelected, newIndexSelected){
    setState(() {
      this._currentUnit = newValueSelected;
      this.unitStatus = newIndexSelected;
      //print('select--${units}');
    });
  }*/

  /*void _confirmDelShowAlert(int id, valProduct) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันลบรายการ'),
          actions: <Widget>[
            FlatButton(
              color: Colors.red,
              child: Text('ลบ', style: TextStyle(fontSize: 18, color: Colors.white),),
              onPressed: (){
                showDialogDelConfirm(id);
                //Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.green,
              child: Text('แก้ไข', style: TextStyle(fontSize: 18, color: Colors.white)),
              onPressed: (){
                setState(() {
                  editOrderDialog(valProduct, 1);
                });
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/

  showDialogDelConfirm(id) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("แจ้งเตือน"),
          content: Text("ยืนยันลบรายการสินค้า"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              color: Colors.green,
              child: Text("ตกลง",style: TextStyle(color: Colors.white, fontSize: 18),),
              onPressed: () {
                removeOrder(id);
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  removeOrder(int id) async{
    await databaseHelper.removeOrder(id);
    getOrderAll();
    showToastRemove();

    //add notify order
    blocCountOrder.getOrderCount();

  }

  void initState(){
    super.initState();
    getOrderAll();
    getProductTop();

  }

  showToastAddFast(){
    Fluttertoast.showToast(
        msg: "เพิ่มรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3
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
      blocCountOrder.getOrderCount();

      //setState(() {
        getOrderAll();
      //});

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

      //setState(() {
        getOrderAll();
      //});

    }
    //Navigator.pushReplacementNamed(context, '/Home');

  }

  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('สินค้าในตะกร้า'),
          actions: <Widget>[
            IconButton(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                icon: Stack(
                  children: <Widget>[
                    Icon(Icons.shopping_basket, size: 40,),
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
                  if(orders.length == 0){
                    _showAlertCheckOrder();
                  }else{
                    selectShip();
                  }

                  //Navigator.pushReplacementNamed(context, '/Order');
                }
            )
          ],
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                  child: PreferredSize(
                    preferredSize: Size.fromHeight(41.0),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Text('คุณมี แต้มสมนาคุณ ${freeLimit.toInt()} แต้ม', style: TextStyle(fontSize: 18, color: Colors.purple), ),
                          ),
                        ],
                      ),
                    ),
                  )
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([

                ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),

                  itemBuilder: (context, int index){
                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                      onTap: (){
                        //setState(() {
                        editOrderDialog(orders[index], 0);
                        //});
                      },
                      leading: Stack(
                        children: <Widget>[
                          Image.network('https://www.wangpharma.com/cms/product/${orders[index]['pic']}',fit: BoxFit.cover, width: 70, height: 70,),
                          (orders[index]['proStatus'] == 2)?
                          Container(
                            padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                            width: 30,
                            height: 20,
                            color: Colors.red,
                            child: Text('Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          ) : Container(
                            padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                            width: 30,
                            height: 20,
                          )
                        ],
                      ),
                      title: Text('${orders[index]['name']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${orders[index]['code']}'),
                          (orders[index]['proStatus'] == 2)
                            ? Text('สั่งขั้นต่ำ ${orders[index]['proLimit']} : ${orders[index]['unit1']}', style: TextStyle(color: Colors.red),)
                            : Text(''),
                          Text('จำนวนที่สั่ง ${orders[index]['amount']} : ${orders[index]['unit']}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),),
                        ],
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.list, size: 40,),
                          onPressed: (){
                            //_confirmDelShowAlert(orders[index]['id'], orders[index]);
                            editOrderDialog(orders[index], 0);
                          }
                      ),
                    );
                  },
                  itemCount: orders != null ? orders.length : 0,
                ),
                Divider(
                  color: Colors.black,
                ),
                Center(
                  child: Text('*** 10 อันดับสินค้าขายดีประจำเดือน ***', style: TextStyle(fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.bold,) ),
                ),
                Divider(
                  color: Colors.black,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  //controller: _scrollController,
                  itemBuilder: (context, int index){
                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10, 1, 10, 1),
                      onTap: (){
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => productDetailPage(product: productTop[index]))).then((value){
                          setState(() {
                            getOrderAll();
                          });
                        });
                      },
                      leading: Stack(
                        children: <Widget>[
                          Image.network('https://www.wangpharma.com/cms/product/${productTop[index].productPic}', fit: BoxFit.cover, width: 70, height: 70,),
                          (productTop[index].productProStatus == '2')?
                          Container(
                            padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                            width: 30,
                            height: 20,
                            color: Colors.red,
                            child: Text('Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          ) : Container(
                            padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                            width: 30,
                            height: 20,
                          )
                        ],
                      ),
                      title: Text('${productTop[index].productName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${productTop[index].productCode}'),
                          Text('${productTop[index].productNameENG}', style: TextStyle(color: Colors.blue), overflow: TextOverflow.ellipsis),
                          (productTop[index].productProLimit != "" && productTop[index].productProStatus == '2')
                              ? Text('สั่งขั้นต่ำ ${productTop[index].productProLimit} : ${productTop[index].productUnit1}', style: TextStyle(color: Colors.red))
                              : Text(''),
                        ],
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.add_to_photos, color: Colors.teal, size: 40,),
                          onPressed: (){
                              //setState(() {
                                addToOrderFast(productTop[index]);
                                //getOrderAll();
                              //});
                          }
                      ),
                    );
                  },
                  itemCount: productTop != null ? productTop.length : 0,
                ),
              ]),
            )
          ],
        )
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  _SliverAppBarDelegate({ this.child });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return child;
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => child.preferredSize.height;

  @override
  // TODO: implement minExtent
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return false;
  }

}
