import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:intl/intl.dart';

import 'package:wang_shop/get_product_free.dart';


class SummaryOrderPage extends StatefulWidget {
  @override
  _SummaryOrderPageState createState() => _SummaryOrderPageState();
}

class _SummaryOrderPageState extends State<SummaryOrderPage> {

  final formatter = new NumberFormat("#,##0.00");

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List orders = [];
  var sumAmount = 0.0;
  var freeLimit = 0.0;

  getOrderAll() async{
    var res = await databaseHelper.getOrder();
    print(res);

    res.forEach((order) =>
        sumAmount = sumAmount + (order['priceA'] * order['amount'])
    );

    freeLimit = sumAmount*0.01;
    if(freeLimit.toInt() >= 30){
      print('แต้ม-${freeLimit.toInt()}');
    }

    //print(sumAmount);

    setState(() {
      orders = res;
    });
  }

  void initState(){
    super.initState();
    getOrderAll();
  }

  getFreeProductSelect(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        contentPadding: EdgeInsets.fromLTRB(1, 1, 1, 1),
        title: Text('เลือกสินค้าแถมตามจำนวนแต้ม\n คุณมี ${freeLimit.toInt()}แต้ม', style: TextStyle(fontSize: 17),),
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SimpleDialogOption(
                  child: RaisedButton(
                    onPressed: (){

                    },
                    textColor: Colors.white,
                    color: Colors.purple,
                    //padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "ตกลง",
                    ),
                  ),
                ),
                getProductFreePage(score: freeLimit.toInt()),
                Padding(
                  padding: EdgeInsets.all(40),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    if(freeLimit.toInt() >= 30){
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('สรุปรายการสั่งจอง'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.list,size: 30,),
                onPressed: (){

                }
            )
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Center(
                child: Text('ยอดรวม ${formatter.format(sumAmount)} บาท', style: TextStyle(fontSize: 30), ),
              ),
              RaisedButton(
                onPressed: (){
                  getFreeProductSelect();
                },
                textColor: Colors.white,
                color: Colors.purple,
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  "เลือกรายการสมนาคุณ",
                ),
              ),
              Center(
                child: Text('แต้มสมนาคุณ ${freeLimit.toInt()} แต้ม', style: TextStyle(fontSize: 18, color: Colors.purple), ),
              ),
              Divider(
                color: Colors.black,
              ),
              Expanded(
                child: ListView.builder(
                  //separatorBuilder: (context, index) => Divider(
                  //color: Colors.black,
                  //),
                  itemBuilder: (context, int index){
                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                      leading: Image.network('http://www.wangpharma.com/cms/product/${orders[index]['pic']}',fit: BoxFit.cover, width: 70, height: 70,),
                      title: Text('${orders[index]['code']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${orders[index]['name']}'),
                          Text('จำนวน ${orders[index]['amount']} : ${orders[index]['unit']}',
                            style: TextStyle(fontSize: 18, color: Colors.red),),
                        ],
                      ),
                      trailing: Text('${formatter.format(orders[index]['priceA']*orders[index]['amount'])} บาท'),
                    );
                  },
                  itemCount: orders != null ? orders.length : 0,
                ),
              ),
            ],
          ),
        ),
      );
    }else{
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('สรุปรายการสั่งจอง'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.list,size: 30,),
                onPressed: (){

                }
            )
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Center(
                child: Text('ยอดรวม ${formatter.format(sumAmount)} บาท', style: TextStyle(fontSize: 30), ),
              ),
              RaisedButton(
                onPressed: (){

                },
                textColor: Colors.white,
                color: Colors.green,
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  "ยืนยันการสั่งจอง",
                ),
              ),
              Divider(
                color: Colors.black,
              ),
              Expanded(
                child: ListView.builder(
                  //separatorBuilder: (context, index) => Divider(
                  //color: Colors.black,
                  //),
                  itemBuilder: (context, int index){
                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                      leading: Image.network('http://www.wangpharma.com/cms/product/${orders[index]['pic']}',fit: BoxFit.cover, width: 70, height: 70,),
                      title: Text('${orders[index]['code']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${orders[index]['name']}'),
                          Text('จำนวน ${orders[index]['amount']} : ${orders[index]['unit']}',
                            style: TextStyle(fontSize: 18, color: Colors.red),),
                        ],
                      ),
                      trailing: Text('${formatter.format(orders[index]['priceA']*orders[index]['amount'])} บาท'),
                    );
                  },
                  itemCount: orders != null ? orders.length : 0,
                ),
              ),
            ],
          ),
        ),
      );
    }
    

  }
}
