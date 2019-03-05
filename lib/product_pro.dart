import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/product_model.dart';
import 'package:wang_shop/product_detail.dart';

class ProductProPage extends StatefulWidget {
  @override
  _ProductProPageState createState() => _ProductProPageState();
}

class _ProductProPageState extends State<ProductProPage> {

  ScrollController _scrollController = new ScrollController();

  //Product product;
  List productAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Pro";

  var product;

  getProduct() async{

    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=$perPage&act=$act');

    //print('http://wangpharma.com/API/product.php?PerPage=$perPage&act=$act');

    if(res.statusCode == 200){
      //var jsonRes = json.decode(res.body);
      //print(jsonRes);

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        /*for(var u in jsonData){
          Product product = Product(u['id'], u['nproductMain'], u['pcode'], u['nproductENG'], u['pic']);

          //print(u['nproductMain']);

          productAll.add(product);

        }*/

        jsonData.forEach((products) => productAll.add(products));
        perPage = productAll.length;

        print(productAll);
        print(productAll.length);

        return productAll;

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

    _scrollController.addListener((){
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        getProduct();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: isLoading ? CircularProgressIndicator()
            :ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, int index){
                        return ListTile(
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => productDetailPage(product: productAll[index])));
                          },
                          leading: Image.network('http://www.wangpharma.com/cms/product/${productAll[index]['pic']}',width: 70, height: 70,),
                          title: Text('${productAll[index]['nproductMain']}'),
                          subtitle: Text('${productAll[index]['nproductENG']}'),
                          trailing: Icon(Icons.shopping_basket),
                        );
                      },
                      itemCount: productAll != null ? productAll.length : 0,
            ),


    );
  }

}