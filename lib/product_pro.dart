import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ProductProPage extends StatefulWidget {
  @override
  _ProductProPageState createState() => _ProductProPageState();
}

class _ProductProPageState extends State<ProductProPage> {

  ScrollController _scrollController = new ScrollController();

  List product;
  bool isLoading = true;
  int perPage = 30;

  getProduct(int page, String act) async{

    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=$page&act=$act');

    //print('http://wangpharma.com/API/product.php?PerPage=$page&act=$act');

    if(res.statusCode == 200){
      //var jsonRes = json.decode(res.body);
      //print(jsonRes);

      setState(() {
        isLoading = false;
        product = json.decode(res.body);

        print(product);
        print(product.length);

      });

      //print(product);
      //print(product.length);

    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProduct(perPage,'Pro');

    _scrollController.addListener((){
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        perPage = product.length + 30;
        print("per-$perPage");
        getProduct(perPage,'Pro');
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
            : ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, int index){
                return ListTile(
                  onTap: (){},
                  leading: Image.network('http://www.wangpharma.com/cms/product/${product[index]['pic']}',width: 70, height: 70,),
                  title: Text('${product[index]['nproduct']}'),
                  subtitle: Text('${product[index]['nproductENG']}'),
                  trailing: Icon(Icons.shopping_basket),
                );
              },
              itemCount: product != null ? product.length : 0,
            ),
    );
  }

}