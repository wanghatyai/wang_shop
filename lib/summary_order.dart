import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';


class SummaryOrderPage extends StatefulWidget {
  @override
  _SummaryOrderPageState createState() => _SummaryOrderPageState();
}

class _SummaryOrderPageState extends State<SummaryOrderPage> {

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

  @override
  Widget build(BuildContext context) {
    
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
                child: Text('ยอดรวม 9999,99 บาท', style: TextStyle(fontSize: 30), ),
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
                      trailing: Text('999 บาท'),
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
