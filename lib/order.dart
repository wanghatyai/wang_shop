import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List orders = [];

  getOrderAll() async{
    var res = await databaseHelper.getOrder();
    print(res);

    setState(() {
      orders = res;
    });
  }

  void initState(){
    super.initState();
    getOrderAll();

  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการสินค้า'),
      ),
      body: ListView.builder(
          itemBuilder: (context, int index){
            return ListTile(
              title: Text('${orders[index]['code']}'),
            );
          },
          itemCount: orders != null ? orders.length : 0,
          ),
    );
  }
}
