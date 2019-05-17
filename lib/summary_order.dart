import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/get_product_free.dart';
import 'package:wang_shop/view_product_free.dart';

import 'package:wang_shop/home.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';


class SummaryOrderPage extends StatefulWidget {
  @override
  _SummaryOrderPageState createState() => _SummaryOrderPageState();
}

class _SummaryOrderPageState extends State<SummaryOrderPage> {

  BlocCountOrder blocCountOrder;

  final formatter = new NumberFormat("#,##0.00");

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List ordersFree = [];
  List orders = [];
  var sumAmount = 0.0;
  var freeLimit = 0.0;

  var priceNowAll = [];

  getOrderAll() async{

    var resFree = await databaseHelper.getOrderFree();
    var res = await databaseHelper.getOrder();
    var resUser = await databaseHelper.getList();

    var userCredit;

    userCredit = resUser[0]['credit'];

    var priceCredit;
    var priceNow;


    print(resFree);
    print(res);
    print('User${userCredit}');

    res.forEach((order) {

          if(userCredit == 'A'){
            priceCredit = order['priceA'];
          }else if(userCredit == 'B'){
            priceCredit = order['priceB'];
          }else{
            priceCredit = order['priceC'];
          }


        if(order['unitStatus'] == 1){

          sumAmount = sumAmount + ((priceCredit * order['unitQty3']) * order['amount']);
          priceNow = priceCredit*order['unitQty3'];
          priceNowAll.add(priceNow);
          print('----${priceNow}');

        }

        if(order['unitStatus'] == 2){

          sumAmount = sumAmount + ((priceCredit * order['unitQty2']) * order['amount']);
          priceNow = priceCredit*order['unitQty2'];
          priceNowAll.add(priceNow);
          print('----${priceNow}');

        }

        if(order['unitStatus'] == 3){

          sumAmount = sumAmount + ((priceCredit * order['unitQty1']) * order['amount']);
          priceNow = priceCredit*order['unitQty1'];
          priceNowAll.add(priceNow);
          print('----${priceNow}');

        }

      }
    );

    freeLimit = sumAmount*0.01;
    if(freeLimit.toInt() >= 30){
      print('แต้ม-${freeLimit.toInt()}');
    }

    print(priceNowAll);

    setState(() {
      ordersFree = resFree;
      orders = res;
    });
  }


  void initState(){
    super.initState();
    getOrderAll();
  }

  getFreeProductSelect(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        contentPadding: EdgeInsets.fromLTRB(1, 1, 1, 1),
        title: Text('เลือกสินค้าแถมตามจำนวนแต้ม\n คุณมี ${freeLimit.toInt()}แต้ม', style: TextStyle(fontSize: 17),),
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                getProductFreePage(score: freeLimit.toInt()),
                Padding(
                  padding: EdgeInsets.all(40),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  viewFreeProductSelect(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        contentPadding: EdgeInsets.fromLTRB(1, 1, 1, 1),
        title: Text('สินค้าแถมที่คุณเลือก', style: TextStyle(fontSize: 17),),
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                viewProductFreePage(),
                Padding(
                  padding: EdgeInsets.all(40),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  showDialogConfirm() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("ยืนยันการทำรายการ"),
          content: Text("รายการสั่งจองของท่านได้ส่งถึงทางร้านแล้ว\nขอบคุณที่ไว้วางใจจากเรา \nบริษัท วังเภสัชฟาร์มาซูติคอล ขอบคุณค่ะ"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              color: Colors.green,
              child: Text("ตกลง",style: TextStyle(color: Colors.white, fontSize: 18),),
              onPressed: () {
                //Navigator.pop(context);
                Navigator.popUntil(context, ModalRoute.withName('/Home'));
              },
            ),
          ],
        );
      },
    );
  }

  confirmOrder() async{

    List pID = [];
    List qty = [];
    List ptype = [];

    List fID = [];
    List fQty = [];

    var pick;
    var pay;

    var userID;

    var resFree = await databaseHelper.getOrderFree();
    var res = await databaseHelper.getOrder();
    var resShipAndPay = await databaseHelper.getShipAndPay();
    var resUser = await databaseHelper.getList();

    res.forEach((order) {
      pID.add(order['productID']);
      qty.add(order['amount']);
      ptype.add(order['unitStatus']);
    });

    resFree.forEach((orderFree) {
      fID.add(orderFree['productID']);
      fQty.add(orderFree['amount']);
    });

    pick = resShipAndPay[0]['ship'];
    pay = resShipAndPay[0]['pay'];

    userID = resUser[0]['idUser'];

    var url = 'http://wangpharma.com/API/confirm.php';

    Map<String, dynamic> data = {
      'pIDc': pID,
      'qtyc': qty,
      'ptype': ptype,
      'pick': pick,
      'pay': pay,
      'fID': fID,
      'fQty': fQty,
      'userID': userID,
    };

    var body = json.encode(data);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: body);

    if(response.statusCode == 200){

      await databaseHelper.removeAll();
      await databaseHelper.removeAllOrderFree();
      showDialogConfirm();
    }

    //showDialogConfirm();

    //print('${pID}-${qty}-${ptype}\n');
    //print('${fID}-${fQty}\n');
    //print('${pick}-${pay}\n');
    //print('${userID}\n');

    print(body);
    //print(data);
    print("${response.statusCode}");
    //print("${response.body}");

    blocCountOrder.clearOrderCount();
  }

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    if(freeLimit.toInt() >= 30){
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('สรุปรายการสั่งจอง'),
          actions: <Widget>[
            /*IconButton(
                icon: Icon(Icons.list,size: 40,),
                onPressed: (){

                }
            )*/
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Center(
                child: Text('ยอดรวม ${formatter.format(sumAmount)} บาท', style: TextStyle(fontSize: 30), ),
              ),
              Row(
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: (){
                      getFreeProductSelect();
                    },
                    textColor: Colors.white,
                    color: Colors.purple,
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "เลือกรายการแถม",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  RaisedButton(
                    onPressed: (){
                      viewFreeProductSelect();
                    },
                    textColor: Colors.white,
                    color: Colors.deepOrange,
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "ดูรายการแถม",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  RaisedButton(
                    onPressed: (){
                      confirmOrder();
                    },
                    textColor: Colors.white,
                    color: Colors.green,
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "ยืนยันการสั่งจอง",
                    ),
                  ),
                ],
              ),
              Center(
                child: Text('คุณมี แต้มสมนาคุณ ${freeLimit.toInt()} แต้ม', style: TextStyle(fontSize: 18, color: Colors.purple), ),
              ),
              Divider(
                color: Colors.black,
              ),
              Expanded(
                child: ListView.builder(
                  //separatorBuilder: (context, index) => Divider(
                  //color: Colors.black,
                  //),
                  itemBuilder: (context, int index){
                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                      leading: Image.network('http://www.wangpharma.com/cms/product/${orders[index]['pic']}',fit: BoxFit.cover, width: 70, height: 70,),
                      title: Text('${orders[index]['name']}', style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${orders[index]['code']}'),
                          Text('จำนวน ${orders[index]['amount']} : ${orders[index]['unit']}',
                            style: TextStyle(fontSize: 18, color: Colors.red),),
                        ],
                      ),
                      trailing: Text('${formatter.format(priceNowAll[index]*orders[index]['amount'])} บาท'),
                    );
                  },
                  itemCount: orders != null ? orders.length : 0,
                ),
              ),
            ],
          ),
        ),
      );
    }else{
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('สรุปรายการสั่งจอง'),
          actions: <Widget>[
            /*IconButton(
                icon: Icon(Icons.list,size: 30,),
                onPressed: (){

                }
            )*/
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Center(
                child: Text('ยอดรวม ${formatter.format(sumAmount)} บาท', style: TextStyle(fontSize: 30), ),
              ),
              RaisedButton(
                onPressed: (){
                  confirmOrder();
                },
                textColor: Colors.white,
                color: Colors.green,
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  "ยืนยันการสั่งจอง",
                ),
              ),
              Divider(
                color: Colors.black,
              ),
              Expanded(
                child: ListView.builder(
                  //separatorBuilder: (context, index) => Divider(
                  //color: Colors.black,
                  //),
                  itemBuilder: (context, int index){
                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                      leading: Image.network('http://www.wangpharma.com/cms/product/${orders[index]['pic']}',fit: BoxFit.cover, width: 70, height: 70,),
                      title: Text('${orders[index]['name']}', style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${orders[index]['code']}'),
                          Text('จำนวน ${orders[index]['amount']} : ${orders[index]['unit']}',
                            style: TextStyle(fontSize: 18, color: Colors.red),),
                        ],
                      ),
                      trailing: Text('${formatter.format(priceNowAll[index]*orders[index]['amount'])} บาท'),
                    );
                  },
                  itemCount: orders != null ? orders.length : 0,
                ),
              ),
            ],
          ),
        ),
      );
    }
    

  }
}
