import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/ship_dialog.dart';
import 'package:wang_shop/pay_dialog.dart';
import 'package:wang_shop/summary_order.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List orders = [];

  List units = [];
  String _currentUnit;

  int selectedRadioTileShip;
  int selectedRadioTilePay;

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

  saveEditOrderDialog(id, unit, amount) async {
    Map order = {
      'id': id,
      'unit': unit,
      'amount': amount,
    };
    await databaseHelper.updateOrder(order);
    getOrderAll();
  }

  editOrderDialog(order, closeDialog){

    units = [];

    //if(_currentUnit.isEmpty){
      _currentUnit = order['unit'].toString();
    //}else{
      //_currentUnit = this._currentUnit;
    //}

    if(order['unit1'].toString() != "NULL"){
      units.add(order['unit1'].toString());
    }
    if(order['unit2'].toString() != "NULL"){
      units.add(order['unit2'].toString());
    }
    if(order['unit3'].toString() != "NULL"){
      units.add(order['unit3'].toString());
    }

    print(_currentUnit);
    print(units);

    TextEditingController editAmount = TextEditingController();

    editAmount.text = order['amount'].toString();

    return showDialog(context: context, builder: (context) {
        return SimpleDialog(
          title: Text('แก้ไขรายการ'),
          children: <Widget>[
            Padding(
             padding: EdgeInsets.all(10),
             child: Text('${order['name']}'),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "จำนวน",
                      ),
                      keyboardType: TextInputType.number,
                      controller: editAmount,
                    ),
                  ),
                  Expanded(
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
                  )
                ],
              ),
            ),

            SimpleDialogOption(
              onPressed: (){

                    saveEditOrderDialog(order['id'],this._currentUnit,editAmount.text);
                    //print(order['id']);
                    //print(this._currentUnit);
                    //print(editAmount.text);
                    if(closeDialog == 1){
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    }else{
                      Navigator.pop(context);
                    }

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

  selectShip(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: Text('เลือกวิธีการรับสินค้า'),
        children: <Widget>[
          ShipDialogPage(),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Divider(
            color: Colors.black,
          ),
          SimpleDialogOption(
            onPressed: (){
              selectPay();
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

  selectPay(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: Text('เลือกวิธีชำระเงิน'),
        children: <Widget>[
          //Text('จำนวน'),
          PayDialogPage(),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Divider(
            color: Colors.black,
          ),
          SimpleDialogOption(
            onPressed: (){
              /*GestureDetector(
                onTap: (){
                  this.showOverlay().overlayEntry.remove();
                  print('tttt');
                },
              );*/
              Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryOrderPage()));
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
      this._currentUnit = newValueSelected;
      //print('select--${units}');
    });
  }

  void _confirmDelShowAlert(int id, valProduct) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันลบรายการ'),
          actions: <Widget>[
            FlatButton(
              child: Text('ลบ'),
              onPressed: (){
                removeOrder(id);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('แก้ไข'),
              onPressed: (){
                setState(() {
                  editOrderDialog(valProduct, 1);
                });
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  removeOrder(int id) async{
    await databaseHelper.removeOrder(id);
    getOrderAll();
    showToastRemove();
    showOverlay();
  }

  void initState(){
    super.initState();
    getOrderAll();
    //selectedRadioTileShip = 1;
    //selectedRadioTilePay = 1;
  }

  /*setSelectRadioTileShip(int val){
    setState(() {
      selectedRadioTileShip = val;
    });
  }
  setSelectRadioTilePay(int val){
    setState(() {
      selectedRadioTilePay = val;
    });
  }*/

  showOverlay() async{

    var countOrder = await databaseHelper.countOrder();
    print(countOrder[0]['countOrderAll']);

    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 25,
          right: 30,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.red,
            child: Text("${countOrder[0]['countOrderAll']}",style: TextStyle(color: Colors.white)),
          ),
        )
    );

    overlayState.insert(overlayEntry);
    //await Future.delayed(Duration(seconds: 2));
    //overlayEntry.remove();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการสินค้า'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check_box),
              onPressed: (){
                selectShip();
                //Navigator.pushReplacementNamed(context, '/Order');
              }
          )
        ],
      ),
      body: ListView.builder(
        //separatorBuilder: (context, index) => Divider(
          //color: Colors.black,
        //),
        itemBuilder: (context, int index){
          return ListTile(
              contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
              onTap: (){
                //setState(() {
                  editOrderDialog(orders[index], 0);
                //});
              },
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
              trailing: IconButton(
                  icon: Icon(Icons.list, size: 30,),
                  onPressed: (){
                    _confirmDelShowAlert(orders[index]['id'], orders[index]);
                  }
              ),
          );
        },
        itemCount: orders != null ? orders.length : 0,
      ),
    );
  }
}
