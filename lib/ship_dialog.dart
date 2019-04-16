import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';


class ShipDialogPage extends StatefulWidget {
  @override
  _ShipDialogPageState createState() => _ShipDialogPageState();
}

class _ShipDialogPageState extends State<ShipDialogPage> {

  int selectedRadioTileShip;
  //int selectedRadioTilePay;
  String codeUser;
  List user = [];
  List statusShip = [];
  int idStatusShip;
  int initalStatusShip;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  checkStatusShipAndPay() async {

    var checkStatus = await databaseHelper.getShipAndPay();
    var getMember = await databaseHelper.getList();

    user = getMember;
    codeUser = user[0]['code'];

    if(checkStatus.isEmpty){
      Map statusShipAndPay = {
        'codeuser': codeUser,
        'ship': 1,
        'pay': 1,
      };
      await databaseHelper.saveShipAndPay(statusShipAndPay);
      print('add status ship and pay');
    }else{
      //initalStatusShip = checkStatus[0]['ship'];
      idStatusShip = checkStatus[0]['id'];

      //print(initalStatusShip);
    }
  }

  @override
  void initState(){
    super.initState();

    selectedRadioTileShip = 1;
    checkStatusShipAndPay();

    //print(initalStatusShip);
  }

  saveShipStatus(id, codeUser, ship) async {
    Map order = {
      'id': id,
      'ship': ship,
      'codeuser': codeUser,
    };
    await databaseHelper.updateShip(order);
    //getOrderAll();
  }

  setSelectRadioTileShip(int val){
    setState(() {
      selectedRadioTileShip = val;
      saveShipStatus(idStatusShip, codeUser, val);
    });
  }

  _selectShip(){
    //return showDialog(context: context, builder: (context) {
     return Column(
        children: <Widget>[
          //Text('จำนวน'),
          RadioListTile(
            title: Text('คุณลูกค้ามารับสินค้าด้วยตัวเอง'),
            activeColor: Colors.green,
            value: 1,
            groupValue: selectedRadioTileShip,
            //selected: true,
            onChanged: (val){
              setSelectRadioTileShip(val);
            },
          ),
          RadioListTile(
            title: Text('ทางร้านวังจัดส่งให้โดยฝาก(รถตู้)'),
            activeColor: Colors.green,
            value: 3,
            groupValue: selectedRadioTileShip,
            //selected: false,
            onChanged: (val){

              setSelectRadioTileShip(val);
            },
          ),
          RadioListTile(
            title: Text('ทางร้านวังจัดส่งให้โดยฝาก(Taxi)'),
            activeColor: Colors.green,
            value: 4,
            groupValue: selectedRadioTileShip,
            //selected: false,
            onChanged: (val){
              setSelectRadioTileShip(val);
            },
          ),
          RadioListTile(
            title: Text('ทางร้านวังจัดส่งให้โดยฝาก(รถทัวร์)'),
            activeColor: Colors.green,
            value: 2,
            groupValue: selectedRadioTileShip,
            //selected: false,
            onChanged: (val){
              setSelectRadioTileShip(val);
            },
          ),
          RadioListTile(
            title: Text('ทางร้านวังจัดส่งให้โดยฝาก(ขนส่งอื่นๆ)'),
            activeColor: Colors.green,
            value: 5,
            groupValue: selectedRadioTileShip,
            //selected: false,
            onChanged: (val){
              setSelectRadioTileShip(val);
            },
          ),
          RadioListTile(
            title: Text('บริการขนส่งของวังเภสัช'),
            activeColor: Colors.green,
            value: 6,
            groupValue: selectedRadioTileShip,
            //selected: false,
            onChanged: (val){
              setSelectRadioTileShip(val);
            },
          ),
        ],

      );
    //});
  }

  @override
  Widget build(BuildContext context) {
    return _selectShip();
  }
}
