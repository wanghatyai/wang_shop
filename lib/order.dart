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
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check_box),
              onPressed: (){
                //Navigator.pushReplacementNamed(context, '/Order');
              }
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, int index){
          return ListTile(
              onTap: (){

              },
              leading: Image.network('http://www.wangpharma.com/cms/product/${orders[index]['pic']}',width: 70, height: 70,),
              title: Text('${orders[index]['code']}'),
              subtitle: Row(
                children: <Widget>[
                  Expanded(child: Text('${orders[index]['name']}')),
                  Expanded(child: Text('จำนวน ${orders[index]['amount']} : ${orders[index]['unit']}')),
                ],
              ),
              trailing: Icon(Icons.delete_forever, color: Colors.red),
          );
        },
        itemCount: orders != null ? orders.length : 0,
      ),
    );
  }
}
