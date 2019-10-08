import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wang_shop/news_model.dart';

import 'package:wang_shop/order.dart';
import 'package:wang_shop/search_auto_out.dart';
import 'package:wang_shop/news_detail.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';



class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {

  BlocCountOrder blocCountOrder;

  ScrollController _scrollController = new ScrollController();

  //Product product;
  List <News>newsAll = [];
  bool isLoading = true;
  int perPage = 30;
  String act = "News";

  getNews() async{

    final res = await http.get('https://wangpharma.com/API/news.php?PerPage=$perPage&act=$act');

    if(res.statusCode == 200){

      setState(() {
        isLoading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) => newsAll.add(News.fromJson(products)));
        perPage = perPage + 30;

        print(newsAll);
        print(perPage);

        return newsAll;

      });


    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNews();

    _scrollController.addListener((){
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        getNews();
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

    blocCountOrder = BlocProvider.of(context);

    return Scaffold(
      body: isLoading ? CircularProgressIndicator()
          :ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, int index){
          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(10, 1, 10, 1),
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => newsDetailPage(news: newsAll[index])));
            },
            leading: Image.network('https://www.wangpharma.com/wang/${newsAll[index].newsImages}', fit: BoxFit.cover, width: 70, height: 70,),
            title: Text('${newsAll[index].newsTopic}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            subtitle: Text('${newsAll[index].newsDetail}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            trailing: IconButton(
                icon: Icon(Icons.format_list_bulleted, color: Colors.teal, size: 40,),
                onPressed: (){
                  //addToOrderFast(productAll[index]);
                }
            ),
          );
        },
        itemCount: newsAll != null ? newsAll.length : 0,
      ),

    );
  }
}
