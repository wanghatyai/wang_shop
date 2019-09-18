import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/database_helper.dart';
import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/product_detail.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class ProductHotMonthPage extends StatefulWidget {
  @override
  _ProductHotMonthPageState createState() => _ProductHotMonthPageState();
}

class _ProductHotMonthPageState extends State<ProductHotMonthPage> {

  BlocCountOrder blocCountOrder;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  //Product product;
  List <Product>productTop = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Top";

  getProductTop() async{

    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=$perPage&act=$act');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => productTop.add(Product.fromJson(products)));
        perPage = productTop.length;

        print(productTop);
        print(productTop.length);

        return productTop;

      });

    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductTop();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  showToastAddFast(){
    Fluttertoast.showToast(
        msg: "เพิ่มรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3
    );
  }

  @override
  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    return Scaffold(
      body: isLoading ? CircularProgressIndicator()
          :GridView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        //controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, int index){
          return InkWell(
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => productDetailPage(product: productTop[index])));
            },
            child: Card(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Image.network('https://www.wangpharma.com/cms/product/${productTop[index].productPic}', fit: BoxFit.cover, width: 200,),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      //alignment: Alignment.topLeft,
                      child: Column(
                        children: <Widget>[
                          //Text('${productTop[index].productCode}', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Text('${productTop[index].productName}', style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                    icon: Icon(Icons.add_to_photos, color: Colors.teal, size: 30,),
                                    onPressed: (){
                                      //addToOrderFast(productTop[index]);
                                    }
                                ),
                              )
                            ],
                          )

                        ],
                      ),
                    ),
                  ],
                )
            ),
          );
        },
        itemCount: productTop != null ? productTop.length : 0,
      ),


    );
  }
}
