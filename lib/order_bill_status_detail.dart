import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:wang_shop/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wang_shop/order_bill_model.dart';

import 'package:wang_shop/order.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class OrderBillStatusDetailPage extends StatefulWidget {

  var orderID;
  OrderBillStatusDetailPage({Key key, this.orderID}) : super(key: key);

  @override
  _OrderBillStatusDetailPageState createState() => _OrderBillStatusDetailPageState();
}

class _OrderBillStatusDetailPageState extends State<OrderBillStatusDetailPage> {

  final formatter = new NumberFormat("#,##0.00");

  BlocCountOrder blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  //Product product;
  List <OrderBill>orderBillDetailAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Detail";
  List statusOrderBillDetail = ['ยังไม่มีสถานะ','พิมพ์บิล','จัดสินค้า','จัดส่ง','รอการอนุมัติ'];
  var userName;
  var userCredit;
  var sumAmount = 0.0;

  var priceNowAll = [];

  getOrderBillDetail() async{

    var resUser = await databaseHelper.getList();
    var userID = resUser[0]['idUser'];
    userName = resUser[0]['name'];
    userCredit = resUser[0]['credit'];
    var priceCredit;
    var priceNow;

    final res = await http.get('https://wangpharma.com/API/orderBill.php?act=$act&orderID=${widget.orderID.orderBillMainId}');
    //print('https://wangpharma.com/API/orderBill.php?act=$act&orderID=${widget.orderID.orderBillId}');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBills){

                  orderBillDetailAll.add(OrderBill.fromJson(orderBills));

                  if(orderBills['stype'] == 2){
                    priceCredit = orderBills['priceA'];
                  }else{
                    if(userCredit == 'A'){
                      priceCredit = orderBills['priceA'];
                    }else if(userCredit == 'B'){
                      priceCredit = orderBills['priceB'];
                    }else{
                      priceCredit = orderBills['priceC'];
                    }
                  }

                  if(orderBills['type'] == 1){

                    sumAmount = sumAmount + ((priceCredit * orderBills['unitQty3']) * orderBills['pno']);
                    priceNow = priceCredit*orderBills['unitQty3'];
                    priceNowAll.add(priceNow);
                    print('----$priceNow');

                  }

                  if(orderBills['type'] == 2){

                    sumAmount = sumAmount + ((priceCredit * orderBills['unitQty2']) * orderBills['pno']);
                    priceNow = priceCredit*orderBills['unitQty2'];
                    priceNowAll.add(priceNow);
                    print('----$priceNow');

                  }

                  if(orderBills['type'] == 3){

                    sumAmount = sumAmount + ((priceCredit * orderBills['unitQty1']) * orderBills['pno']);
                    priceNow = priceCredit*orderBills['unitQty1'];
                    priceNowAll.add(priceNow);
                    print('----$priceNow');

                  }

                });

        print(orderBillDetailAll);
        print(orderBillDetailAll.length);

        return orderBillDetailAll;

      });

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

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        //title: Text(widget.product.productName.toString()),
        title: Text("รายละเอียดรายการสินค้า"),
      ),
      body: isLoading ? CircularProgressIndicator()
          :ListView.separated(
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
            },
            leading: Image.network('https://www.wangpharma.com/cms/product/${orderBillDetailAll[index].orderBillProductPic}',fit: BoxFit.cover, width: 70, height: 70,),
            title: Text('${orderBillDetailAll[index].orderBillProductName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${orderBillDetailAll[index].orderBillProductCode}'),
                Text('จำนวน ${orderBillDetailAll[index].orderBillProductSelectQty} : ${orderBillDetailAll[index].orderBillProductUnit1}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),),
              ],
            ),
            trailing: Text('฿', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          );
        },
        itemCount: orderBillDetailAll != null ? orderBillDetailAll.length : 0,
      ),
    );
  }
}
