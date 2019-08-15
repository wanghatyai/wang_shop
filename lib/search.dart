import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ค้นหาสินค้า"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: (){
              showSearch(context: context, delegate: DataSearch());
            },
          )
        ],
      ),
      drawer: Drawer(),
    );
  }

}


class DataSearch extends SearchDelegate<String> {

  var products = [];
  var recentProducts = [];

  searchProduct(searchVal) async{

    //products = [];

    final res = await http.get('https://wangpharma.com/API/product.php?SearchVal=$searchVal&act=Search');

    if(res.statusCode == 200){

      //setState(() {

        var jsonData = json.decode(res.body);

        //products = json.decode(res.body);
        //recentProducts = json.decode(res.body);
        jsonData.forEach(([product, i]) {
          if(product['nproductMain'] != 'null'){
            products.add(product['nproductMain']);
          }
          print(product['nproductMain']);
        });

        print(products);

        return products;

      //});

    }else{
      throw Exception('Failed load Json');
    }
    //print(searchVal);
    //print(json.decode(res.body));

  }

  @override
  List<Widget> buildActions(BuildContext context) {
    
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: (){
            query = "";
          }
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: transitionAnimation,
        ),
        onPressed: (){
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    
    return Center(
      child: Text(query, style: TextStyle(color: Colors.red)),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    //print(query);
    searchProduct(query);
    
    final suggestionList = query.isEmpty
        ? recentProducts
        : products.where((p) => p.startsWith(query)).toList();

    print(products);
    
    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: (){
            showResults(context);
          },
          leading: Icon(Icons.shop),
          title: RichText(
            text: TextSpan(
              text: suggestionList[index].substring(0, query.length),
              style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold
              ),
              children: [
                TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(color: Colors.grey)
                )
              ]
            ),
          ),
        ),
        itemCount: suggestionList.length,
    );
  }

}
