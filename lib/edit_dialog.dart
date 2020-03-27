import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

import 'package:wang_shop/order.dart';

class EditDialogPage extends StatefulWidget {

  EditDialogPage({Key key, this.units, this.orderE}): super(key: key);

  final List units;
  var orderE;

  @override
  _EditDialogPageState createState() => _EditDialogPageState();
}

class _EditDialogPageState extends State<EditDialogPage> {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  TextEditingController editAmount = TextEditingController();

  BlocCountOrder blocCountOrder;


  String _currentUnit;
  var unitStatus;

  void initState(){
    super.initState();
    _currentUnit = widget.orderE['unit'];
    unitStatus = widget.orderE['unitStatus'];
    editAmount.text = widget.orderE['amount'].toString();
  }


  saveEditOrderDialog(id, unit, unitStatusVal, amount) async {
    Map order = {
      'id': id,
      'unit': unit,
      'unitStatus': unitStatusVal,
      'amount': amount,
    };
    await databaseHelper.updateOrder(order);
  }

  _onDropDownItemSelected(newValueSelected, newIndexSelected){
    setState(() {
      this._currentUnit = newValueSelected;
      this.unitStatus = newIndexSelected;

      //saveEditOrderDialog(updateOrderUnit['id'], newValueSelected, newIndexSelected, updateOrderAmount);
    });
  }

  showDialogDelConfirm(id) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("แจ้งเตือน"),
          content: Text("ยืนยันลบรายการสินค้า"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              color: Colors.green,
              child: Text("ตกลง",style: TextStyle(color: Colors.white, fontSize: 18),),
              onPressed: () {
                removeOrder(id);
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /*showDialogLimitProduct() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("แจ้งเตือน"),
          content: Text("จำนวนที่เลือกต่ำกว่าจำนวนขั้นต่ำรายการโปร"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              color: Colors.red,
              child: Text("ตกลง",style: TextStyle(color: Colors.white, fontSize: 18),),
              onPressed: () {
                //Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }*/

  removeOrder(int id) async{
    await databaseHelper.removeOrder(id);
    //getOrderAll();
    showToastRemove();

    //add notify order
    blocCountOrder.getOrderCount();

  }

  showToastRemove(){
    Fluttertoast.showToast(
        msg: "ลบรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3
    );
  }

  showToastAmountLessProductProLimit(){
    Fluttertoast.showToast(
        msg: "จำนวนที่เลือกต่ำกว่าจำนวนขั้นต่ำรายการโปร",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 10
    );
  }

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    return SimpleDialog(
      titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 1),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('แก้ไขรายการ'),
          FlatButton(
            color: Colors.red,
            child: Text('ลบ', style: TextStyle(fontSize: 18, color: Colors.white),),
            onPressed: (){
              showDialogDelConfirm(widget.orderE['id']);
              //Navigator.of(context).pop();
            },
          ),
        ],
      ),
      children: <Widget>[
        Divider(
          color: Colors.green,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: Text('${widget.orderE['name']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "จำนวน",
                    contentPadding: EdgeInsets.all(4),
                  ),
                  keyboardType: TextInputType.number,
                  controller: editAmount,
                ),
              ),
              Expanded(
                child: DropdownButton(
                  isExpanded: true,
                  hint: Text("เลือกหน่วยสินค้า",style: TextStyle(fontSize: 18)),
                  items: widget.units.map((dropDownStringItem){
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem, style: TextStyle(fontSize: 18)),
                    );
                  }).toList(),
                  onChanged: (newValueSelected){
                    var tempIndex = widget.units.indexOf(newValueSelected)+1;
                    _onDropDownItemSelected(newValueSelected, tempIndex);
                    print(this._currentUnit);
                    print(tempIndex);

                  },
                  value: _currentUnit,

                ),
              ),
            ],
          ),
        ),

        SimpleDialogOption(
          onPressed: (){

            print(this._currentUnit);
            print(this.unitStatus);
            print(widget.orderE['proStatus']);
            print(editAmount.text);
            print(widget.orderE['proLimit']);

            if(widget.orderE['proStatus'] == 2 && int.parse(editAmount.text) < widget.orderE['proLimit']){
              //showDialogLimitProduct();
              //print('lesssssssssss');
              showToastAmountLessProductProLimit();
            }

            saveEditOrderDialog(widget.orderE['id'], this._currentUnit, this.unitStatus, editAmount.text);
            //print(order['id']);
            //print(this._currentUnit);
            //print(editAmount.text);
            /*if(closeDialog == 1){
              getOrderAll();
              Navigator.of(context).pop();
              Navigator.pop(context);
              print('C1');

            }else{*/
              //getOrderAll();
              Navigator.pop(context);
              print('C2');
            //}

          },
          child: Container(
              padding: EdgeInsets.fromLTRB(1, 10, 1, 10),
              color: Colors.green,
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                        'ตกลง',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18, fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                ],
              )
          ),
        ),
      ],

    );
  }
}
