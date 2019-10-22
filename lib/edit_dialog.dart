import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';

class EditDialogPage extends StatefulWidget {

  EditDialogPage({Key key, this.units,}): super(key: key);

  final List units;

  @override
  _EditDialogPageState createState() => _EditDialogPageState();
}

class _EditDialogPageState extends State<EditDialogPage> {

  String _currentUnit;
  var unitStatus;

  _onDropDownItemSelected(newValueSelected, newIndexSelected){
    setState(() {
      this._currentUnit = newValueSelected;
      this.unitStatus = newIndexSelected;
      //print('select--${units}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
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

    );
  }
}
