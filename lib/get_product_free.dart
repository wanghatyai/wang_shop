import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class getProductFreePage extends StatefulWidget {

  var score;
  getProductFreePage({Key key, this.score}) : super (key: key);

  @override
  _getProductFreePageState createState() => _getProductFreePageState();
}

class _getProductFreePageState extends State<getProductFreePage> {

  List productFree = [];

  getProduct() async{

    final res = await http.get('http://wangpharma.com/API/product.php?Score=${widget.score}&act=Free');

    if(res.statusCode == 200){

      setState(() {
        //isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => productFree.add(products));
        //perPage = productFree.length;

        print(productFree);
        print(productFree.length);

        return productFree;

      });


    }else{
      throw Exception('Failed load Json');
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

                    },
                    contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                    leading: Image.network('http://www.wangpharma.com/cms/product/${productFree[index]['pic']}',fit: BoxFit.cover, width: 70, height: 70,),
                    title: Text('${productFree[index]['pcode']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${productFree[index]['nproduct']}'),
                        Text('${productFree[index]['freePrice']} แต้ม : ${productFree[index]['unit1']}',
                          style: TextStyle(fontSize: 18, color: Colors.red),),
                      ],
                    ),
                    trailing: Text('${index}'),
                  );
                },
                itemCount: productFree != null ? productFree.length : 0,
              )
         );
  }
}
