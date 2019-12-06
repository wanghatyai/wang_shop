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
    var orderBillType;
    var orderBillProductSelectQty;

    final res = await http.get('https://wangpharma.com/API/orderBill.php?act=$act&orderID=${widget.orderID.orderBillMainId}');
    //print('https://wangpharma.com/API/orderBill.php?act=$act&orderID=${widget.orderID.orderBillId}');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBills)=> orderBillDetailAll.add(OrderBill.fromJson(orderBills)));

        for(var index = 0; index < orderBillDetailAll.length; index++){

          /*if(int.parse(orderBillDetailAll[index].orderBillProductProStatus) == 2){
            priceCredit = orderBillDetailAll[index].orderBillProductPriceA;
          }else{
            if(userCredit == 'A'){
              priceCredit = orderBillDetailAll[index].orderBillProductPriceA;
            }else if(userCredit == 'B'){
              priceCredit = orderBillDetailAll[index].orderBillProductPriceB;
            }else{
              priceCredit = orderBillDetailAll[index].orderBillProductPriceC;
            }
          }*/

          priceCredit = double.parse(orderBillDetailAll[index].orderBillProductSelectPrice);
          orderBillType = int.parse(orderBillDetailAll[index].orderBillProductSelectUnit);
          orderBillProductSelectQty = int.parse(orderBillDetailAll[index].orderBillProductSelectQty);

          if(orderBillType == 1){

            sumAmount = sumAmount + ((priceCredit * int.parse(orderBillDetailAll[index].orderBillProductUnitQty3)) * orderBillProductSelectQty);
            priceNow = priceCredit * int.parse(orderBillDetailAll[index].orderBillProductUnitQty3);
            priceNowAll.add(priceNow);
            print('----$priceNow');

          }

          if(orderBillType == 2){

            sumAmount = sumAmount + ((priceCredit * int.parse(orderBillDetailAll[index].orderBillProductUnitQty2)) * orderBillProductSelectQty);
            priceNow = priceCredit * int.parse(orderBillDetailAll[index].orderBillProductUnitQty2);
            priceNowAll.add(priceNow);
            print('----$priceNow');

          }

          if(orderBillType == 3){

            sumAmount = sumAmount + ((priceCredit * int.parse(orderBillDetailAll[index].orderBillProductUnitQty1)) * orderBillProductSelectQty);
            priceNow = priceCredit * int.parse(orderBillDetailAll[index].orderBillProductUnitQty1);
            priceNowAll.add(priceNow);
            print('----$priceNow');

          }

        }

        print(sumAmount);
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
      body: Column(
        children: <Widget>[
          Center(
            child: Text('ยอดรวม ${formatter.format(sumAmount)} บาท', style: TextStyle(fontSize: 30), ),
          ),
          Expanded(
            child: isLoading ? CircularProgressIndicator()
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
                  /*trailing: IconButton(
                      icon: Icon(Icons.add_to_photos, color: Colors.teal, size: 40,),
                      onPressed: (){
                        //addToOrderFast(productAll[index]);
                      }
                  ),*/
                  trailing: Text('฿${formatter.format(priceNowAll[index]*int.parse(orderBillDetailAll[index].orderBillProductSelectQty))}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                );
              },
              itemCount: orderBillDetailAll != null ? orderBillDetailAll.length : 0,
            ),
          )
        ],
      ),
    );
  }
}
