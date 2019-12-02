import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  BlocCountOrder blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  //Product product;
  List <OrderBill>orderBillDetailAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Detail";
  List statusOrderBillDetail = ['ยังไม่มีสถานะ','พิมพ์บิล','จัดสินค้า','จัดส่ง','รอการอนุมัติ'];
  var userName;

  getOrderBillDetail() async{

    var resUser = await databaseHelper.getList();
    var userID = resUser[0]['idUser'];
    userName = resUser[0]['name'];

    final res = await http.get('https://wangpharma.com/API/orderBill.php?act=$act&orderID=${widget.orderID.orderBillId}');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBills) => orderBillDetailAll.add(OrderBill.fromJson(orderBills)));

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
            contentPadding: EdgeInsets.fromLTRB(10, 1, 10, 1),
            onTap: (){
              /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderBillStatusDetailPage(orderID: orderBillAll[index])));*/
            },
            //leading: Image.network('https://www.wangpharma.com/cms/product/${productAll[index].productPic}', fit: BoxFit.cover, width: 70, height: 70),
            title: Text('${orderBillDetailAll[index].orderBillProductCode}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${orderBillDetailAll[index].orderBillProductName}'),
              ],
            ),
            trailing: IconButton(
                icon: Icon(Icons.view_list, color: Colors.purple, size: 40,),
                onPressed: (){
                  //addToOrderFast(productAll[index]);
                }
            ),
          );
        },
        itemCount: orderBillDetailAll != null ? orderBillDetailAll.length : 0,
      ),
    );
  }
}
