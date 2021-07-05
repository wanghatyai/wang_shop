import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:carousel_pro/carousel_pro.dart';

class MainSlidePage extends StatefulWidget {
  @override
  _MainSlidePageState createState() => _MainSlidePageState();
}

class _MainSlidePageState extends State<MainSlidePage> {

  var slides = [];
  double heightValForDevice = 150;

  getSlideAll() async{
    final res = await http.get(Uri.https('wangpharma.com', '/API/slides.php', {'position': 'P0', 'act': 'Slide'}));

    if(res.statusCode == 200){

      if (mounted) {
        setState(() {
          //isLoading = false;

          var jsonData = json.decode(res.body);

          //jsonData.forEach((products) => productTop.add(Product.fromJson(products)));
          jsonData.forEach((slide) =>
              slides.add((NetworkImage(
                  'https://wangpharma.com/wang/images/post-shopping/thumbnail/${slide['pws_images']}'))));

          print(slides);
        });

        return slides;

      }

    }else{
      throw Exception('Failed load Json');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //slides.add(AssetImage('assets/bannerDemo.jpg'));
    getSlideAll();
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
      heightValForDevice = 300;
    }

    return slides.isEmpty ? CircularProgressIndicator() : Container(
      height: heightValForDevice,
      child: Carousel(
        overlayShadow: false,
        borderRadius: true,
        boxFit: BoxFit.contain,
        autoplay: true,
        dotSize: 5,
        indicatorBgPadding: 9,
        images: slides,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(microseconds: 30000),
      ),
    );
  }
}
