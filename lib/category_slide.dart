import 'package:flutter/material.dart';

import 'package:wang_shop/product_pro.dart';
import 'package:wang_shop/product_hot.dart';
import 'package:wang_shop/product_new.dart';
import 'package:wang_shop/product_recom.dart';
import 'package:wang_shop/product_gim.dart';
import 'package:wang_shop/product_category.dart';

class CategorySlidePage extends StatefulWidget {
  @override
  _CategorySlidePageState createState() => _CategorySlidePageState();
}

class _CategorySlidePageState extends State<CategorySlidePage> {
  double marginValForDevice = 0;
  double heightCategorySlide = 80;
  double sizeCategorySlideIcon = 40;

  @override
  Widget build(BuildContext context) {

    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    print(shortestSide);
    if(shortestSide > 600){
      marginValForDevice = 250;
      heightCategorySlide = 120;
      sizeCategorySlideIcon = 80;
    }

    return Container(
      color: Colors.white,
      //margin: EdgeInsets.symmetric(horizontal: marginValForDevice),
      height: heightCategorySlide,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductProPage()));
                print('โปร');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.assistant_photo, color: Colors.green, size: sizeCategorySlideIcon),
                    Text('โปร', style: TextStyle(fontSize: 16))
                  ],
                ),
              )
            ),
            InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductHotPage()));
                  print('ขายดี');
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.monetization_on, color: Colors.amber, size: sizeCategorySlideIcon),
                      Text('ขายดี', style: TextStyle(fontSize: 16))
                    ],
                  ),
                )
            ),
            InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductNewPage()));
                  print('ใหม่');
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.fiber_new, color: Colors.red, size: sizeCategorySlideIcon),
                      Text('ใหม่', style: TextStyle(fontSize: 16))
                    ],
                  ),
                )
            ),
            InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductRecomPage()));
                  print('แนะนำ');
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.thumb_up, color: Colors.blue, size: sizeCategorySlideIcon),
                      Text('แนะนำ', style: TextStyle(fontSize: 16))
                    ],
                  ),
                )
            ),
            InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductGimPage()));
                  print('ของแถม');
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.tag_faces, color: Colors.deepPurple, size: sizeCategorySlideIcon),
                      Text('ของแถม', style: TextStyle(fontSize: 16))
                    ],
                  ),
                )
            ),
            InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCategoryPage()));
                  print('หมวดหมู่');
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.list, color: Colors.pink, size: sizeCategorySlideIcon),
                      Text('หมวดหมู่', style: TextStyle(fontSize: 16))
                    ],
                  ),
                )
            ),

          ],
        ),
      ),
    );
  }
}
