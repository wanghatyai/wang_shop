import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:wang_shop/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wang_shop/product_detail.dart';
import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/order_bill_model.dart';
import 'package:wang_shop/product_hot_m30.dart';

import 'package:fluttertoast/fluttertoast.dart';

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
  List <Product>productAll = [];
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
    //print('https://wangpharma.com/API/orderBill.php?act=$act&orderID=${widget.orderID.orderBillMainId}');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((orderBills)=> orderBillDetailAll.add(OrderBill.fromJson(orderBills)));
        jsonData.forEach((orderBills)=> productAll.add(Product.fromJson(orderBills)));

        for(var index = 0; index < orderBillDetailAll.length; index++){

          //productAll[index].productId = orderBillDetailAll[index].orderBillProductID;
          //productAll[index].productCode = orderBillDetailAll[index].orderBillProductCode;


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

          print('product ID ${productAll[index].productId}');

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

  showToastAddFast(){
    Fluttertoast.showToast(
        msg: "เพิ่มรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3
    );
  }

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("รายละเอียดรายการในบิล"),
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
                Column(
                children: <Widget>[
                  Center(
                    child: Text('ยอดรวม ${formatter.format(sumAmount)} บาท', style: TextStyle(fontSize: 30), ),
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => productDetailPage(product: productAll[index])));
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
                          trailing: IconButton(
                              icon: Icon(Icons.add_to_photos, color: Colors.teal, size: 40,),
                              onPressed: (){
                                addToOrderFast(productAll[index]);
                              }
                          ),
                          //trailing: Text('฿${formatter.format(priceNowAll[index]*int.parse(orderBillDetailAll[index].orderBillProductSelectQty))}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        );
                      },
                      itemCount: orderBillDetailAll != null ? orderBillDetailAll.length : 0,
                    ),
                  Padding(
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
                  ),

                ],
              ),
            ])
           ),
          ],
        ),
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

    }

    //Navigator.pushReplacementNamed(context, '/Home');

  }
}
