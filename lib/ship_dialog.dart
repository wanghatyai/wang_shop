import 'package:flutter/material.dart';

class ShipDialogPage extends StatefulWidget {
  @override
  _ShipDialogPageState createState() => _ShipDialogPageState();
}

class _ShipDialogPageState extends State<ShipDialogPage> {

  int selectedRadioTileShip;
  //int selectedRadioTilePay;

  @override
  void initState(){
    super.initState();
    selectedRadioTileShip = 1;
  }

  setSelectRadioTileShip(int val){
    setState(() {
      selectedRadioTileShip = val;
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
