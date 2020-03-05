import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wang_shop/get_product_free.dart';
import 'package:wang_shop/view_product_free.dart';

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

  List user = [];
  String name;
  String value;
  String userCode;
  String userRoute;
  DateFormat dateFormat;
  Map<String, dynamic> transportationDetail = {};

  List ordersFree = [];
  List orders = [];
  var sumAmount = 0.0;
  var freeLimit = 0.0;

  var priceNowAll = [];

  getUser() async {
    var res = await databaseHelper.getList();
    //print(res);

    setState(() {
      user = res;
      name = user[0]['name'];
      userCode = user[0]['code'];
      userRoute = user[0]['route'];
    });

  }

  getTransportation() async {

    final resTransportation = await http.get('https://wangpharma.com/API/transportation.php?act=TransportationDate&userRoute=$userRoute');
    print('https://wangpharma.com/API/transportation.php?act=TransportationDate&userRoute=$userRoute');

    if(resTransportation.statusCode == 200){

      var jsonData = json.decode(resTransportation.body);

      if(jsonData.isNotEmpty){
        transportationDetail = jsonData[0];

        print(transportationDetail);

        print('TransportationDay--${jsonData.length}');
        var newDateTimeObj2 = DateFormat('yyyy-MM-dd').parse(transportationDetail['Start_In_calendar']);
        //dateFormate = DateFormat("dd-MM-yyyy").format(DateTime.parse("2019-09-30"));
        //dateFormat.format(newDateTimeObj2);
        //print(DateFormat("dd-MM-yyyy").format(DateFormat('yyyy-MM-dd').parse(transportationDetail['Start_In_calendar'])));
        //print(DateFormat('yyyy-MM-dd').parse(overdueBillAllDetail['CBS_Date_Receive']));
        //var newDateTimeObj2 = new DateFormat("dd/MM/yyyy HH:mm:ss").parse("10/02/2000 15:13:09")
      }

    }

    /*if(overdueStatus > 0) {
      this.showDialogOverdue();
    }*/

    //return overdueBillAllDetail;

  }

  getOrderAll() async{

    var resFree = await databaseHelper.getOrderFree();
    var res = await databaseHelper.getOrder();
    var resUser = await databaseHelper.getList();

    var userCredit;

    userCredit = resUser[0]['credit'];

    var priceCredit;
    var priceNow;

    var unitQty1;
    var unitQty2;
    var unitQty3;


    print(resFree);
    print(res);
    print('User$userCredit');

    res.forEach((order) {

      unitQty1 = (order['unitQty1']/order['unitQty1']);
      unitQty2 = (order['unitQty1']/order['unitQty2']);
      unitQty3 = (order['unitQty1']/order['unitQty3']);


          if(order['proStatus'] == 2 && order['amount'] >= order['proLimit']){
              priceCredit = order['priceA'];
          }else{
            if(userCredit == 'A'){
              priceCredit = order['priceA'];
            }else if(userCredit == 'B'){
              priceCredit = order['priceB'];
            }else{
              priceCredit = order['priceC'];
            }
          }


        if(order['unitStatus'] == 1){

          sumAmount = sumAmount + ((priceCredit * unitQty1) * order['amount']);
          priceNow = priceCredit*unitQty1;
          priceNowAll.add(priceNow);

          print('----$priceNow');

        }

        if(order['unitStatus'] == 2){

          sumAmount = sumAmount + ((priceCredit * unitQty2) * order['amount']);
          priceNow = priceCredit*unitQty2;
          priceNowAll.add(priceNow);

          print('----$priceNow');

        }

        if(order['unitStatus'] == 3){

          sumAmount = sumAmount + ((priceCredit * unitQty3) * order['amount']);
          priceNow = priceCredit*unitQty3;
          priceNowAll.add(priceNow);

          print('----$priceNow');

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
    getUser();
    getTransportation();
  }

  getFreeProductSelect(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        contentPadding: EdgeInsets.fromLTRB(1, 1, 1, 1),
        title: Text('เลือกสินค้าแถมตามจำนวนแต้ม\n คุณมี ${freeLimit.toInt()} แต้ม', style: TextStyle(fontSize: 17),),
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Divider(color: Colors.black),
                getProductFreePage(score: freeLimit.toInt()),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('กลับ', style: TextStyle(fontSize: 16),),
                        onPressed: (){
                          //print('freeProductAdd');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text('ดูสินค้าแถมที่เลือก', style: TextStyle(fontSize: 16),),
                        onPressed: (){
                          print('viewProductAdd');
                          Navigator.pop(context);
                          viewFreeProductSelect();
                        },
                      ),
                    ),
                  ],
                ),
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
                Text('คุณมี ${freeLimit.toInt()} แต้ม', style: TextStyle(fontSize: 17),),
                Divider(color: Colors.black),
                viewProductFreePage(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('กลับ', style: TextStyle(fontSize: 16),),
                        onPressed: (){
                          //print('freeProductAdd');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.deepPurple,
                        textColor: Colors.white,
                        child: Text('เลือกสินค้าแถมเพิ่ม', style: TextStyle(fontSize: 16),),
                        onPressed: (){
                          print('freeProductAdd');
                          Navigator.pop(context);
                          getFreeProductSelect();
                        },
                      ),
                    ),
                  ],
                ),
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

  _confirmCheckFreeShowAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ตรวจสอบก่อนยืนยัน'),
          content: Text('คุณลูกค้า\n *กรุณาเลือกสินค้าแถมถ้ายังไม่ได้เลือก\n\n -แต่ถ้าเลือกสินค้าแถมเรียบร้อยแล้ว\n โปรดกดปุ่ม [ยืนยันส่งรายการ]'),
          actions: <Widget>[
            FlatButton(
              color: Colors.purple,
              child: Text('เลือกสินค้าแถม', style: TextStyle(fontSize: 17, color: Colors.white),),
              onPressed: (){
                getFreeProductSelect();
                //Navigator.of(context).pop();
              },
            ),
            Padding(
              padding: EdgeInsets.all(5),
            ),
            FlatButton(
              color: Colors.green,
              child: Text('ยืนยันส่งรายการ', style: TextStyle(fontSize: 16, color: Colors.white),),
              onPressed: (){
                confirmOrder();
                //Navigator.of(context).pop();
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

    var url = 'https://wangpharma.com/API/confirm.php';

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
                    padding: const EdgeInsets.all(5.0),
                    child: new Text(
                      "เลือกสินค้าแถม",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3),
                  ),
                  RaisedButton(
                    onPressed: (){
                      viewFreeProductSelect();
                    },
                    textColor: Colors.white,
                    color: Colors.blue,
                    padding: const EdgeInsets.all(5.0),
                    child: new Text(
                      "ดูสินค้าแถมที่เลือก",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  RaisedButton(
                    onPressed: (){
                        _confirmCheckFreeShowAlert();
                    },
                    textColor: Colors.white,
                    color: Colors.green,
                    padding: const EdgeInsets.all(5.0),
                    child: new Text(
                      "ยืนยันการสั่งจอง",
                       style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
              Center(
                child: Text('คุณมี แต้มสมนาคุณ ${freeLimit.toInt()} แต้ม', style: TextStyle(fontSize: 18, color: Colors.purple)),
              ),
              (transportationDetail['Start_In_calendar'] != null)
                  ? Container(
                      color: Colors.red,
                      child: Center(
                        child: Text('วันที่จัดส่งสินค้า ${DateFormat("dd/MM/yyyy").format(DateFormat('yyyy-MM-dd').parse(transportationDetail['Start_In_calendar']))} เวลาเดินทาง ${transportationDetail['Time_Out']}',
                          style: TextStyle(fontSize: 16, color: Colors.white), ),
                      ),
                    )
                  : Container(),
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
                          Text('จำนวนที่สั่ง ${orders[index]['amount']} : ${orders[index]['unit']}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),),
                          Text("ราคาต่อหน่วย ฿${priceNowAll[index]}", style: TextStyle(color: Colors.blueGrey),),
                        ],
                      ),
                      trailing: Column(
                        children: <Widget>[
                          Text('฿${formatter.format(priceNowAll[index]*orders[index]['amount'])}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              (transportationDetail['Start_In_calendar'] != null)
                  ? Container(
                      color: Colors.red,
                      child: Center(
                        child: Text('วันที่จัดส่งสินค้า ${DateFormat("dd/MM/yyyy").format(DateFormat('yyyy-MM-dd').parse(transportationDetail['Start_In_calendar']))} เวลาเดินทาง ${transportationDetail['Time_Out']}',
                          style: TextStyle(fontSize: 16, color: Colors.white), ),
                      ),
                    )
                  : Container(),
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
                          Text('จำนวนที่สั่ง ${orders[index]['amount']} : ${orders[index]['unit']}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),),
                          Text("ราคาต่อหน่วย ฿${priceNowAll[index]}", style: TextStyle(color: Colors.blueGrey),),
                        ],
                      ),
                      trailing: Text('฿${formatter.format(priceNowAll[index]*orders[index]['amount'])}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
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
