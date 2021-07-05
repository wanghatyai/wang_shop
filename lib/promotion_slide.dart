import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class PromotionSlidePage extends StatefulWidget {
  @override
  _PromotionSlidePageState createState() => _PromotionSlidePageState();
}

class _PromotionSlidePageState extends State<PromotionSlidePage> {

  var slidesPro1 = [];
  var slidesPro2 = [];
  var slidesPro3 = [];

  bool isLoading = true;

  double sizePromotionSlidePic = 200;

  getSlideProP1() async{
    final res = await http.get(Uri.https('wangpharma.com', '/API/slides.php', {'position': 'P1', 'act':'Slide'}));


    if(res.statusCode == 200){

      if (mounted) {
        setState(() {
          isLoading = false;

          var jsonData = json.decode(res.body);

          //jsonData.forEach((products) => productTop.add(Product.fromJson(products)));
          jsonData.forEach((slide) =>
              slidesPro1.add(
                  'https://wangpharma.com/wang/images/post-shopping/thumbnail/${slide['pws_images']}'));

          print(slidesPro1);

        });
        return slidesPro1;
      }

    }else{
      throw Exception('Failed load Json');
    }
  }

  getSlideProP2() async{
    final res = await http.get(Uri.https('wangpharma.com', '/API/slides.php', {'position': 'P2', 'act':'Slide'}));

    if(res.statusCode == 200){

      if (mounted) {
        setState(() {
          isLoading = false;

          var jsonData = json.decode(res.body);

          //jsonData.forEach((products) => productTop.add(Product.fromJson(products)));
          jsonData.forEach((slide) =>
              slidesPro2.add(
                  'https://wangpharma.com/wang/images/post-shopping/thumbnail/${slide['pws_images']}'));

          print(slidesPro2);

        });

        return slidesPro2;
      }

    }else{
      throw Exception('Failed load Json');
    }
  }

  getSlideProP3() async{
    final res = await http.get(Uri.https('wangpharma.com', '/API/slides.php', {'position': 'P3', 'act':'Slide'}));


    if(res.statusCode == 200){

      if (mounted) {
        setState(() {
          isLoading = false;

          var jsonData = json.decode(res.body);

          //jsonData.forEach((products) => productTop.add(Product.fromJson(products)));
          jsonData.forEach((slide) =>
              slidesPro3.add(
                  'https://wangpharma.com/wang/images/post-shopping/thumbnail/${slide['pws_images']}'));

          print(slidesPro3);

        });

        return slidesPro3;
      }

    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //slidesPro1.add(AssetImage('assets/productDemo.jpg'));
    getSlideProP1();
    getSlideProP2();
    getSlideProP3();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    print(shortestSide);
    if(shortestSide > 600){
      sizePromotionSlidePic = 300;
    }

    return isLoading ? CircularProgressIndicator() : Container(
      height: sizePromotionSlidePic,
      child: ListView(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          InkWell(
              onTap: (){
                print('โปร1');
              },
              child: Container(
                width: sizePromotionSlidePic,
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Image.network('${slidesPro1[0]}', fit: BoxFit.fitWidth,),
              ),
          ),
          InkWell(
            onTap: (){
              print('โปร1');
            },
            child: Container(
              width: sizePromotionSlidePic,
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Image.network('${slidesPro2[0]}', fit: BoxFit.fitWidth,),
            ),
          ),
          InkWell(
            onTap: (){
              print('โปร1');
            },
            child: Container(
              width: sizePromotionSlidePic,
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Image.network('${slidesPro3[0]}', fit: BoxFit.fitWidth,),
            ),
          ),
        ],
      ),
    );
  }
}
