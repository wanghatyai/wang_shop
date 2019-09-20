import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';

class MemberPage extends StatefulWidget {
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  var userName;

  getUser() async{

    var resUser = await databaseHelper.getList();
    setState(() {
      userName = resUser[0]['name'];
    });

    print(userName);

    /*final res = await http.get('https://wangpharma.com/API/product.php?act=Cat');

    if(res.statusCode == 200){

      setState(() {

        var jsonDataCat = json.decode(res.body);

        jsonDataCat.forEach((category) {
          categoryAll.add(category);
          categoryNameAll.add(category['name']);

          categoryCodeAll.add(category['code']);
        });

        print(categoryCodeAll);
        return categoryAll;

      });

    }else{
      throw Exception('Failed load Json');
    }*/

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.account_circle, size: 60, color: Colors.white,),
                      Text('${userName}', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Text('ที่อยู่ร้าน : **************', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Icon(Icons.beenhere, size: 40,),
                          Text('ยืนยันรายการ')
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Icon(Icons.check_circle, size: 40,),
                          Text('เตรียมจัดส่ง')
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Icon(Icons.local_shipping, size: 40,),
                          Text('ระหว่างขนส่ง')
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Icon(Icons.comment, size: 40,),
                          Text('ข้อเสนอแนะ')
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
