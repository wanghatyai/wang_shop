import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:wang_shop/category_slide.dart';
import 'package:wang_shop/product_hot_m.dart';
import 'package:wang_shop/promotion_slide.dart';
import 'package:wang_shop/product_hot_m30.dart';
import 'package:wang_shop/main_slide.dart';

class HomeNewPage extends StatefulWidget {
  @override
  _HomeNewPageState createState() => _HomeNewPageState();
}

class _HomeNewPageState extends State<HomeNewPage> {

  double heightValForDevice = 1050;
  double heightValForDevice30 = 4150;

  /*Widget slideBanner = Container(
    height: 150,
    child: Carousel(
      overlayShadow: false,
      borderRadius: true,
      boxFit: BoxFit.cover,
      autoplay: true,
      dotSize: 5,
      indicatorBgPadding: 9,
      images: [
        AssetImage('assets/bannerDemo.jpg'),
        AssetImage('assets/bannerDemo1.jpg'),
      ],
      animationCurve: Curves.fastOutSlowIn,
      animationDuration: Duration(microseconds: 15000),
    ),
  );*/

  @override
  Widget build(BuildContext context) {

    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    print(shortestSide);
    if(shortestSide > 600){
      heightValForDevice = 600;
      heightValForDevice30 = 2000;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              MainSlidePage(),
              CategorySlidePage(),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 2, 0, 2),
                child: Text('/// สินค้าขายดีประจำเดือน ///', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              ),
              Container(
                height: heightValForDevice,
                child: ProductHotMonthPage(),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text('/// โปรโมชั่นพิเศษ ///', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              ),
              PromotionSlidePage(),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 2, 0, 2),
                child: Text('/// สินค้าขายดีประจำเดือน ///', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              ),
              Container(
                height: heightValForDevice30,
                child: ProductHotMonth30Page(),
              ),

            ])
          ),
        ],
      ),
    );
  }
}
