import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:wang_shop/NewUI/slideCompany.dart';
import 'package:wang_shop/category_slide.dart';
import 'package:wang_shop/home.dart';
import 'package:wang_shop/product_hot_m.dart';
import 'package:wang_shop/promotion_slide.dart';
import 'package:wang_shop/product_hot_m30.dart';
import 'package:wang_shop/main_slide.dart';
import 'package:wang_shop/search_auto_out.dart';

class HomeNewPage extends StatefulWidget {
  @override
  _HomeNewPageState createState() => _HomeNewPageState();
}

class _HomeNewPageState extends State<HomeNewPage> {

  double heightValForDevice = 1260;
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
      heightValForDevice = 800;
      heightValForDevice30 = 2600;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                height: MediaQuery.of(context).size.height / 11,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white,Colors.white],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.red.shade400,width: 1.8,
                        ),
                        color: Colors.white),
                    child: Row(
                        children: <Widget>[
                          Padding(padding: const EdgeInsets.only(left: 4),),
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => searchAutoOutPage()));
                            },
                            child: Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    colors: [Colors.red.shade400,Colors.orange.shade600],
                                  ),
                                ),
                                child: Icon(Icons.search,size: 25, color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 12,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => searchAutoOutPage()));
                                },
                                child: Text(
                                  'ค้นหา',
                                  style: TextStyle(color: Colors.black,fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              Home().createState().scanBarcode();
                            },
                            child: Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  child: Icon(Icons.camera_alt_outlined,size: 25,
                                      color: Colors.red[400]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ),
                ),
              ),
              MainSlidePage(),
              SlideCompany(),
              CategorySlidePage(),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 2, 0, 2),
                  color: Colors.red,
                  child: Text('/// สินค้าขายดีประจำเดือน ///', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),
              ),
              Container(
                height: heightValForDevice,
                child: ProductHotMonthPage(),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                color: Colors.red,
                child: Text('/// โปรโมชั่นพิเศษ ///', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),
              ),
              PromotionSlidePage(),
              Container(
                padding: EdgeInsets.fromLTRB(10, 2, 0, 2),
                color: Colors.red,
                child: Text('/// สินค้าขายดีประจำเดือน ///', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),
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
