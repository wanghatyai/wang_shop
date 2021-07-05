import 'package:flutter/material.dart';

class SlideCompany extends StatefulWidget {
  @override
  _SlideCompanyState createState() => _SlideCompanyState();
}

class _SlideCompanyState extends State<SlideCompany> {
  var name = [
    "assets/logoCompany/ozp-logo.png",
    "assets/logoCompany/smoothe.png",
    "assets/logoCompany/dettol.png",
    "assets/logoCompany/mega.png",
    "assets/logoCompany/berlin.png",
    "assets/logoCompany/siam.png",
    //"assets/mobiles.png",
    //"assets/sports_and_more.png",
    //"assets/toys_and_babby.png",
    //"assets/home.png"
  ];

  buildItem(BuildContext context, int index) {
    return Container(
      width: MediaQuery.of(context).size.width / 6,
      height: MediaQuery.of(context).size.height / 11,
      child: Image.asset(
        name[index],
        height: MediaQuery.of(context).size.height / 11,
        width: MediaQuery.of(context).size.width / 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 11,
      child: ListView.builder(
        itemCount: 8,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return buildItem(context, index);
        },
      ),
    );
  }
}