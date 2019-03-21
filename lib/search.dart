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

  final products = [
    "test1",
    "test2",
    "test3"
  ];

  final recentProducts = [
    "reTest5",
    "reTest6",
    "reTest7"
  ];

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
    
    final suggestionList = query.isEmpty
        ? recentProducts
        : products.where((p) => p.startsWith(query)).toList();
    
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
