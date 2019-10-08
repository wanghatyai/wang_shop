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
                height: 1050,
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
                height: 4150,
                child: ProductHotMonth30Page(),
              ),

            ])
          ),
        ],
      ),
    );
  }
}
