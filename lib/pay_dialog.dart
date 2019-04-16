import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';

class PayDialogPage extends StatefulWidget {
  @override
  _PayDialogPageState createState() => _PayDialogPageState();
}

class _PayDialogPageState extends State<PayDialogPage> {

  int selectedRadioTilePay;
  String codeUser;
  int idStatusShip;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  checkStatusShipAndPay() async {

    var checkStatus = await databaseHelper.getShipAndPay();
    var getMember = await databaseHelper.getList();

    codeUser = getMember[0]['code'];
    idStatusShip = checkStatus[0]['id'];

  }

  @override
  void initState(){
    super.initState();
    selectedRadioTilePay = 1;
    checkStatusShipAndPay();

  }

  savePayStatus(id, codeUser, pay) async {
    Map order = {
      'id': id,
      'pay': pay,
      'codeuser': codeUser,
    };
    await databaseHelper.updatePay(order);
  }

  setSelectRadioTilePay(int val){
    setState(() {
      selectedRadioTilePay = val;
      savePayStatus(idStatusShip, codeUser, val);
    });
  }

  selectPay(){
    //return showDialog(context: context, builder: (context) {
      return Column(
        children: <Widget>[
          //Text('จำนวน'),
          RadioListTile(
            title: Text('เครดิต(ลูกหนี้)'),
            activeColor: Colors.green,
            value: 1,
            groupValue: selectedRadioTilePay,
            onChanged: (val){
              setSelectRadioTilePay(val);
            },
          ),
          RadioListTile(
            title: Text('เงินสด'),
            activeColor: Colors.green,
            value: 2,
            groupValue: selectedRadioTilePay,
            onChanged: (val){
              setSelectRadioTilePay(val);
            },
          ),
          RadioListTile(
            title: Text('เช็ค'),
            activeColor: Colors.green,
            value: 3,
            groupValue: selectedRadioTilePay,
            onChanged: (val){
              setSelectRadioTilePay(val);
            },
          ),
          RadioListTile(
            title: Text('บัตรเครดิต'),
            activeColor: Colors.green,
            value: 4,
            groupValue: selectedRadioTilePay,
            onChanged: (val){
              setSelectRadioTilePay(val);
            },
          ),
        ],

      );
    //});
  }

  @override
  Widget build(BuildContext context) {
    return selectPay();
  }
}
