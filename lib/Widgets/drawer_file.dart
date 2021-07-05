import 'package:flutter/material.dart';


class Drawerfile extends StatefulWidget {
  @override
  _DrawerfileState createState() => _DrawerfileState();
}

class _DrawerfileState extends State<Drawerfile> {
  List<DrawerItemModel> drawerItemModel = [];

  @override
  void initState() {
    super.initState();
    addDrawerItem();
  }

  addDrawerItem() {
    //drawerItemModel = List<DrawerItemModel>();
    drawerItemModel.add(DrawerItemModel("Wang Pharmaceutical",
        ""));
    drawerItemModel.add(DrawerItemModel("ยาแผนปัจจุบัน",
        ""));
    drawerItemModel.add(DrawerItemModel("ยาสมุนไพรและยาแผนโบราณ",
        ""));
    drawerItemModel.add(DrawerItemModel("ยาอม",
        ""));
    drawerItemModel.add(DrawerItemModel("เครื่องสำอางและของใช้ส่วนตัว",
        ""));
    drawerItemModel.add(DrawerItemModel("อุปกรณ์การแพทย์",
        ""));
    drawerItemModel.add(DrawerItemModel("นมและอาหารเสริมทางการแพทย์",
        ""));
    drawerItemModel.add(DrawerItemModel("ช่องปากและฟัน",
        ""));
    drawerItemModel.add(DrawerItemModel("สินค้าแม่และเด็ก",
        ""));
    drawerItemModel.add(DrawerItemModel("อื่นๆ",
        ""));
    drawerItemModel.add(DrawerItemModel("สินค้าแนะนำ",
        ""));
    drawerItemModel.add(DrawerItemModel("สินค้าโปรโมชั่น",
        ""));
    drawerItemModel.add(DrawerItemModel("การซื้อของฉัน",
        ""));
    drawerItemModel.add(DrawerItemModel("คะแนนของฉัน",
        ""));
    drawerItemModel.add(DrawerItemModel("ตะกร้าของฉัน",
        ""));
    drawerItemModel.add(DrawerItemModel("สิ่งที่ฉันถูกใจ",
        ""));
    drawerItemModel.add(DrawerItemModel("บัญชีของฉัน",
        ""));
    drawerItemModel.add(DrawerItemModel("Notification Preferences", ""));
    drawerItemModel.add(DrawerItemModel("Gift Card", ""));
    drawerItemModel.add(DrawerItemModel("My Chats", ""));
    drawerItemModel.add(DrawerItemModel("Help Centre", ""));
    drawerItemModel.add(DrawerItemModel("Legal", ""));
  }

  buildItem(BuildContext context, int index) {
    if (drawerItemModel[index].imageRes != null) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Image.network(
                    drawerItemModel[index].imageRes,
                    height: 15,
                    width: 15,
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Text(
                    drawerItemModel[index].name,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          index == 0 || index ==  9 || index == 11 || index == 15
              ? Container(
            color: Colors.grey,
            height: 1,
          )
              : SizedBox(
            height: 0,
          )
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 10, left: 20),
        child: Text(
          drawerItemModel[index].name,
          style: TextStyle(fontSize: 15),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ListView(
      children: <Widget>[
        Container(
          height: size.height / 10,
          color: Color(0xFFE64A19),
          child: Center(
            child: ListTile(
                title: Text(
                  'Home',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                leading: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                trailing:Image.asset("assets/flutter2.png", height: size.height / 20,
                  width: size.width/10,)
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: drawerItemModel.length,
          itemBuilder: (context, index) {
            return buildItem(context, index);
          },
        )
      ],
    );
  }
}

class DrawerItemModel {
  String _name;
  String _imageRes;

  DrawerItemModel(this._name, this._imageRes);

  String get imageRes => _imageRes;

  String get name => _name;
}