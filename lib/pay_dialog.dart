import 'package:flutter/material.dart';

class PayDialogPage extends StatefulWidget {
  @override
  _PayDialogPageState createState() => _PayDialogPageState();
}

class _PayDialogPageState extends State<PayDialogPage> {

  int selectedRadioTilePay;

  @override
  void initState(){
    super.initState();
    selectedRadioTilePay = 1;
  }

  setSelectRadioTilePay(int val){
    setState(() {
      selectedRadioTilePay = val;
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
