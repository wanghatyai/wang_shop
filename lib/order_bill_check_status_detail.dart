import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:wang_shop/database_helper.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/order_bill_TC_temps_model.dart';

class OrderBillCheckStatusDetailPage extends StatefulWidget {

  var OrderBillval;
  var NotificationSent;
  OrderBillCheckStatusDetailPage({Key? key, this.OrderBillval, this.NotificationSent}) : super(key: key);

  @override
  _OrderBillCheckStatusDetailPageState createState() => _OrderBillCheckStatusDetailPageState();
}

class _OrderBillCheckStatusDetailPageState extends State<OrderBillCheckStatusDetailPage> {

  final formatter = new NumberFormat("#,##0.00");

  BlocCountOrder? blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List <OrderBillTCTemps>orderBillDetailAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Detail";
  List statusOrderBillDetail = ['ยังไม่มีสถานะ','พิมพ์บิล','จัดสินค้า','จัดส่ง','รอการอนุมัติ'];
  var userName;
  var userCredit;
  var sumAmount = 0.0;

  var priceNowAll = [];

  var orderBillCode;

  getOrderBillDetail() async{

    if(widget.NotificationSent == 1){
      orderBillCode = widget.OrderBillval;
    }else{
      orderBillCode = widget.OrderBillval.orderBillCode;
    }

    var resUser = await databaseHelper.getList();
    var userID = resUser[0]['idUser'];
    userName = resUser[0]['name'];
    userCredit = resUser[0]['credit'];

    var orderBill_TC_PsumPrice;
    var priceNow;
    var orderBillType;
    var orderBillProductSelectQty;

    final res = await http.get(Uri.https('wangpharma.com', '/API/orderBill.php', {'PerPage': perPage.toString(), 'act': 'CheckStatusOrderBillDetail', 'orderBillCode': orderBillCode}));


    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBills)=> orderBillDetailAll.add(OrderBillTCTemps.fromJson(orderBills)));

        for(var index = 0; index < orderBillDetailAll.length; index++){

          orderBill_TC_PsumPrice = double.parse(orderBillDetailAll[index].orderBillTCPsumPrice!);

          sumAmount = sumAmount + orderBill_TC_PsumPrice;

        }

      });

      return orderBillDetailAll;

    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrderBillDetail();
  }

  showToastAddFast(){
    Fluttertoast.showToast(
        msg: "เพิ่มรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("รายละเอียดรายการในบิล"),
        /*actions: <Widget>[
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
              })
        ],*/
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.blue,
                      child: Center(
                        child: Text('ยอดรวม ${formatter.format(sumAmount)} บาท', style: TextStyle(fontSize: 30, color: Colors.white), ),
                      ),
                    ),
                    isLoading ? CircularProgressIndicator()
                        :ListView.separated(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Colors.black,
                        );
                      },
                      //controller: _scrollController,
                      itemBuilder: (context, int index){
                        return ListTile(
                          contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                          onTap: (){
                            //setState(() {
                            //editOrderDialog(orders[index], 0);
                            //});
                            /*Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => productDetailPage(product: productAll[index])));*/
                          },
                          leading: Image.network('https://www.wangpharma.com/cms/product/${orderBillDetailAll[index].orderBillTCPpic}',fit: BoxFit.cover, width: 70, height: 70,),
                          title: Text('${orderBillDetailAll[index].orderBillTCPname}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${orderBillDetailAll[index].orderBillTCPcode}'),
                              Text('จำนวน ${orderBillDetailAll[index].orderBillTCPq} : ${orderBillDetailAll[index].orderBillTCPunit}',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),),
                              Text("ราคาต่อหน่วย ฿${orderBillDetailAll[index].orderBillTCPprice}", style: TextStyle(color: Colors.blueGrey),),
                            ],
                          ),
                          /*trailing: IconButton(
                              icon: Icon(Icons.add_to_photos, color: Colors.teal, size: 40,),
                              onPressed: (){
                                addToOrderFast(productAll[index]);
                              }
                          ),*/
                          //trailing: Text('฿${formatter.format(priceNowAll[index]*int.parse(orderBillDetailAll[index].orderBillProductSelectQty))}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        );
                      },
                      itemCount: orderBillDetailAll != null ? orderBillDetailAll.length : 0,
                    ),
                    /*Padding(
                      padding: EdgeInsets.fromLTRB(10, 2, 0, 2),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.deepOrange,
                        child: Text('/// สินค้าขายดีประจำเดือน ///', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),),
                      ),
                    ),
                    Container(
                      height: 4150,
                      child: ProductHotMonth30Page(),
                    ),*/

                  ],
                ),
              ])
          ),
        ],
      ),
    );
  }
}
