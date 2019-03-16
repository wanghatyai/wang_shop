import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List orders = [];

  List units = ['ขวด','กลอง'];
  String _currentUnit;

  getOrderAll() async{
    var res = await databaseHelper.getOrder();
    print(res);

    setState(() {
      orders = res;
    });
  }

  showToastRemove(){
    Fluttertoast.showToast(
        msg: "ลบรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3
    );
  }

  editOrderDialog(id){
    TextEditingController editAmount = TextEditingController();

    return showDialog(context: context, builder: (context) {
        return SimpleDialog(
          title: Text('แก้ไขรายการ'),
          children: <Widget>[
            //Text('จำนวน'),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "จำนวน",
              ),
              keyboardType: TextInputType.number,
              controller: editAmount,
            ),

            Padding(
              padding: EdgeInsets.all(10),
              child: DropdownButton(
                hint: Text("เลือกหน่วยสินค้า",style: TextStyle(fontSize: 18)),
                items: units.map((dropDownStringItem){
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem, style: TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (newValueSelected){
                  _onDropDownItemSelected(newValueSelected);
                  print(this._currentUnit);

                },
                value: _currentUnit,

              ),
            ),

            SimpleDialogOption(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text(
                  'ตกลง',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold
                  )
              ),
            ),
          ],


        );
    });
  }

  _onDropDownItemSelected(newValueSelected){
    setState(() {
      _currentUnit = newValueSelected;
      //print('select--${units}');
    });
  }

  removeOrder(int id) async{
    await databaseHelper.removeOrder(id);
    getOrderAll();
    showToastRemove();

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
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.black,
        ),
        itemBuilder: (context, int index){
          return ListTile(
              onTap: (){
                editOrderDialog(orders[index]['id']);
              },
              leading: Image.network('http://www.wangpharma.com/cms/product/${orders[index]['pic']}',width: 70, height: 70,),
              title: Text('${orders[index]['code']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${orders[index]['name']}'),
                  Text('จำนวน ${orders[index]['amount']} : หน่วย ${orders[index]['unit']}',
                    style: TextStyle(fontSize: 18),),
                ],
              ),
              trailing: IconButton(
                  icon: Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: (){
                      removeOrder(orders[index]['id']);
                  }
              ),
          );
        },
        itemCount: orders != null ? orders.length : 0,
      ),
    );
  }
}
