import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:wang_shop/database_helper.dart';

import 'package:wang_shop/order_bill_temps_model.dart';
import 'package:wang_shop/order_bill_check_status_detail.dart';

class OrderBillCheckStatusPage extends StatefulWidget {

  var statusVal;
  OrderBillCheckStatusPage({Key key, this.statusVal}) : super(key: key);

  @override
  _OrderBillCheckStatusPageState createState() => _OrderBillCheckStatusPageState();
}

class _OrderBillCheckStatusPageState extends State<OrderBillCheckStatusPage> {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  ScrollController _scrollController = new ScrollController();

  List <OrderBillTemps>orderBillTempsAll = [];
  bool isLoading = true;
  var userName;
  int perPage = 30;
  var act = '';
  var orderStatusText = '';

  getOrderBill() async{

    if(widget.statusVal == 2){
      act = 'CheckStatusOrderBillConfirm';
      orderStatusText = 'เปิดบิล';
    }else if(widget.statusVal == 4){
      act = 'CheckStatusOrderBillPicking';
      orderStatusText = 'จัดสินค้า';
    }else if(widget.statusVal == 6){
      act = 'CheckStatusOrderBillShipping';
      orderStatusText = 'กำลังส่ง';
    }else if(widget.statusVal == 7){
      act = 'CheckStatusOrderBillComplete';
      orderStatusText = 'รับสินค้าแล้ว';
    }

    var resUser = await databaseHelper.getList();
    var userID = resUser[0]['idUser'];
    var userCode = resUser[0]['code'];
    userName = resUser[0]['name'];

    final res = await http.get('https://wangpharma.com/API/orderBill.php?PerPage=$perPage&act=$act&userCode=$userCode');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBills) => orderBillTempsAll.add(OrderBillTemps.fromJson(orderBills)));
        perPage = perPage + 30;

        print(orderBillTempsAll);
        print(orderBillTempsAll.length);

        return orderBillTempsAll;

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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("รายการ - $orderStatusText"),
        ),
        body: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                  delegate: SliverChildListDelegate([
                    /*RaisedButton (
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
                    ),*/
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
                                  MaterialPageRoute(builder: (context) => OrderBillCheckStatusDetailPage(OrderBillval: orderBillTempsAll[index])));
                            },
                            //leading: Image.network('https://www.wangpharma.com/cms/product/${productAll[index].productPic}', fit: BoxFit.cover, width: 70, height: 70),
                            title: Text('${orderBillTempsAll[index].orderBillCode}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('วันที่สั่ง ${orderBillTempsAll[index].orderBillDateAdd}'),
                                orderStatusText == null
                                    ? Text("สถานะ")
                                    : Text('สถานะ $orderStatusText', style: TextStyle(color: Colors.blue)),
                                //Text('วันที่ดำเนินการ ${orderBillTempsAll[index].orderBillDateST} : ${orderBillTempsAll[index].orderBillTimeST}', style: TextStyle(color: Colors.red)),
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
                        itemCount: orderBillTempsAll != null ? orderBillTempsAll.length : 0,
                      ),
                    )
                  ])
              )
            ]
        )
    );
  }
}
