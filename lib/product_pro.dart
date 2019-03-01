import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:wang_shop/product_model.dart';

class ProductProPage extends StatefulWidget {
  @override
  _ProductProPageState createState() => _ProductProPageState();
}

class _ProductProPageState extends State<ProductProPage> {

  ScrollController _scrollController = new ScrollController();

  //Product product;
  List<Product> productAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "Pro";

  getProduct() async{

    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=$perPage&act=$act');

    //print('http://wangpharma.com/API/product.php?PerPage=$page&act=$act');

    if(res.statusCode == 200){
      //var jsonRes = json.decode(res.body);
      //print(jsonRes);

      setState(() {
        isLoading = false;

        //print(productRAW);
        //productAll = Product.fromJson(productRAW);

        //productAll = productRAW.map<String, dynamic>((m) => m as String).toList();
        //var productCon = productRAW as Map<String, dynamic>;

        //print(productCon);

        //productAll = (productRAW as List).map((p) => Product.fromJson(p)).toList();

        var jsonData = json.decode(res.body);

        for(var u in jsonData){
          Product product = Product(u['id'], u['nproductMain'], u['pcode'], u['nproductENG'], u['pic']);

          //print(u['nproductMain']);

          productAll.add(product);

        }
        perPage = perPage + productAll.length;

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
                          onTap: (){},
                          leading: Image.network('http://www.wangpharma.com/cms/product/${productAll[index].productPic}',width: 70, height: 70,),
                          title: Text('${productAll[index].productName}'),
                          subtitle: Text('${productAll[index].productNameENG}'),
                          trailing: Icon(Icons.shopping_basket),
                        );
                      },
                      itemCount: productAll != null ? productAll.length : 0,
            ),


    );
  }

}