import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:wang_shop/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wang_shop/order_bill_model.dart';
import 'package:wang_shop/order_bill_status_detail.dart';

import 'package:wang_shop/order.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class OrderBillStatusPage extends StatefulWidget {
  @override
  _OrderBillStatusPageState createState() => _OrderBillStatusPageState();
}

class _OrderBillStatusPageState extends State<OrderBillStatusPage> {

  BlocCountOrder blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  ScrollController _scrollController = new ScrollController();

  //Product product;
  List <OrderBill>orderBillAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "All";
  List statusOrderBill = ['ยังไม่มีสถานะ','พิมพ์บิล','จัดสินค้า','จัดส่ง','รอการอนุมัติ'];
  var userName;

  DateTime _date = DateTime.now();

  selectDate()async{
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100)
    );

    if(picked != null && picked != _date){
      setState(() {
        _date = picked;
        print(_date.toString().substring(0,10));

        getOrderBillByDate(_date.toString().substring(0,10));
      });
    }
  }

  getOrderBill() async{

    var resUser = await databaseHelper.getList();
    var userID = resUser[0]['idUser'];
    userName = resUser[0]['name'];

    final res = await http.get('https://wangpharma.com/API/orderBill.php?PerPage=$perPage&act=$act&userID=$userID');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBills) => orderBillAll.add(OrderBill.fromJson(orderBills)));
        perPage = perPage + 30;

        print(orderBillAll);
        print(orderBillAll.length);

        return orderBillAll;

      });

    }else{
      throw Exception('Failed load Json');
    }
  }

  getOrderBillByDate(dateSelect) async{

    orderBillAll = [];

    var resUser = await databaseHelper.getList();
    var userID = resUser[0]['idUser'];
    userName = resUser[0]['name'];

    final res = await http.get('https://wangpharma.com/API/orderBill.php?PerPage=$perPage&act=AllByDate&userID=$userID&DateSelect=$dateSelect');
    //print('https://wangpharma.com/API/orderBill.php?PerPage=$perPage&act=AllByDate&userID=$userID&DateSelect=$dateSelect');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBills) => orderBillAll.add(OrderBill.fromJson(orderBills)));
        perPage = perPage + 30;

        print(orderBillAll);
        print(orderBillAll.length);

        return orderBillAll;

      });

    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrderBill();

    _scrollController.addListener((){
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        getOrderBill();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("บิลรายการที่เคยสั่งทั้งหมด"),
        actions: <Widget>[
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
        ],
      ),
      body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                RaisedButton (
                  color: Colors.deepOrange,
                  shape: RoundedRectangleBorder (
                    borderRadius: BorderRadius.all (
                      Radius.circular ( 20 ),
                    ),
                  ),
                  onPressed: (){
                    selectDate();
                  },
                  child: Text (
                    'ค้นหาตามวันที่สั่ง',
                    style: TextStyle (
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  child:isLoading ? CircularProgressIndicator():ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Colors.black,
                      );
                    },
                    controller: _scrollController,
                    itemBuilder: (context, int index){
                      return ListTile(
                        contentPadding: EdgeInsets.fromLTRB(10, 1, 10, 1),
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => OrderBillStatusDetailPage(orderID: orderBillAll[index])));
                        },
                        //leading: Image.network('https://www.wangpharma.com/cms/product/${productAll[index].productPic}', fit: BoxFit.cover, width: 70, height: 70),
                        title: Text('${orderBillAll[index].orderBillCode}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('วันที่สั่ง ${orderBillAll[index].orderBillDate} : ${orderBillAll[index].orderBillTime}'),
                            Text('สถานะ ${statusOrderBill[int.parse(orderBillAll[index].orderBillStatus)]}', style: TextStyle(color: Colors.blue)),
                            Text('วันที่ดำเนินการ ${orderBillAll[index].orderBillDateST} : ${orderBillAll[index].orderBillTimeST}', style: TextStyle(color: Colors.red)),
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
                    itemCount: orderBillAll != null ? orderBillAll.length : 0,
                  ),
                )
              ])
            )
          ]
      )
    );
  }
}
