import 'package:flutter/material.dart';

class PromotionSlidePage extends StatefulWidget {
  @override
  _PromotionSlidePageState createState() => _PromotionSlidePageState();
}

class _PromotionSlidePageState extends State<PromotionSlidePage> {


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          InkWell(
              onTap: (){
                print('โปร1');
              },
              child: Container(
                width: 200,
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Image.asset('assets/productDemo.jpg', fit: BoxFit.fitWidth,),
              ),
          ),
          InkWell(
            onTap: (){
              print('โปร1');
            },
            child: Container(
              width: 200,
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Image.asset('assets/productDemo1.jpg', fit: BoxFit.fitWidth,),
            ),
          ),
          InkWell(
            onTap: (){
              print('โปร1');
            },
            child: Container(
              width: 200,
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Image.asset('assets/productDemo2.jpg', fit: BoxFit.fitWidth,),
            ),
          ),
        ],
      ),
    );
  }
}
