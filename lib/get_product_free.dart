import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wang_shop/product_model.dart';

class getProductFreePage extends StatefulWidget {

  var score;
  getProductFreePage({Key key, this.score}) : super (key: key);

  @override
  _getProductFreePageState createState() => _getProductFreePageState();
}

class _getProductFreePageState extends State<getProductFreePage> {

  List <Product>productFree = [];
  var limitScore = 0;

  getProduct() async{

    final res = await http.get('http://wangpharma.com/API/product.php?Score=${widget.score}&act=Free');

    if(res.statusCode == 200){

      setState(() {
        //isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => productFree.add(Product.fromJson(products)));
        //perPage = productFree.length;

        print(productFree);
        print(productFree.length);

        return productFree;

      });


    }else{
      throw Exception('Failed load Json');
    }
  }

  showDialogLimit() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("ข้ออภัย"),
          content: new Text("คุณเลือกสินค้าเกินจำนวนแต้ม"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("ปิด"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showToastAddFast(){
    Fluttertoast.showToast(
        msg: "เพิ่มรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3
    );
  }

  addProductFree(score){
    print(limitScore);

    if((limitScore+score) > widget.score ){
      showDialogLimit();
      print('NO');
    }else{
      limitScore = limitScore+score;
      showToastAddFast();
      print('add score');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
              child:ListView.builder(
                //separatorBuilder: (context, index) => Divider(
                //color: Colors.black,
                //),
                itemBuilder: (context, int index){
                  return ListTile(
                    onTap: (){
                      setState(() {
                        addProductFree(int.parse(productFree[index].productFreePrice));
                      });
                    },
                    contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                    leading: Image.network('http://www.wangpharma.com/cms/product/${productFree[index].productPic}',fit: BoxFit.cover, width: 70, height: 70,),
                    title: Text('${productFree[index].productCode}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${productFree[index].productName}'),
                        Text('${productFree[index].productFreePrice} แต้ม : ${productFree[index].productUnit1}',
                          style: TextStyle(fontSize: 18, color: Colors.red),),
                      ],
                    ),
                    trailing: Icon(Icons.add, color: Colors.teal, size: 30),
                  );
                },
                itemCount: productFree != null ? productFree.length : 0,
              )
         );
  }
}
