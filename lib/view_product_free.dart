import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class viewProductFreePage extends StatefulWidget {
  @override
  _viewProductFreePageState createState() => _viewProductFreePageState();
}

class _viewProductFreePageState extends State<viewProductFreePage> {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List ordersFree = [];

  getOrderAll() async{

    var resFree = await databaseHelper.getOrderFree();

    print(resFree);
    //print(sumAmount);

    setState(() {
      ordersFree = resFree;
    });
  }

  void initState(){
    super.initState();
    getOrderAll();
  }

  removeOrderFree(int id) async{
    await databaseHelper.removeOrderFree(id);
    getOrderAll();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        //separatorBuilder: (context, index) => Divider(
        //color: Colors.black,
        //),
        itemBuilder: (context, int index){
          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
            leading: Image.network('https://www.wangpharma.com/cms/product/${ordersFree[index]['pic']}',fit: BoxFit.cover, width: 70, height: 70,),
            title: Text('${ordersFree[index]['name']}', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${ordersFree[index]['code']}'),
                Text('${ordersFree[index]['freePrice']} แต้ม ${ordersFree[index]['amount']} : ${ordersFree[index]['unit1']}',
                  style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold),),
              ],
            ),
            trailing: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red, size: 30),
                onPressed: (){
                  removeOrderFree(ordersFree[index]['id']);
                }
            ),
          );
        },
        itemCount: ordersFree != null ? ordersFree.length : 0,
      ),
    );
  }
}
