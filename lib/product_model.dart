import 'package:flutter/material.dart';

class Product{
  final String productId;
  final String productName;
  final String productCode;
  final String productNameENG;
  final String productPic;
  final String productUnit1;
  final String productUnit2;
  final String productUnit3;
  final String productPriceA;
  final String productPriceB;
  final String productPriceC;


  Product({
    this.productId,
    this.productName,
    this.productCode,
    this.productNameENG,
    this.productPic,
    this.productUnit1,
    this.productUnit2,
    this.productUnit3,
    this.productPriceA,
    this.productPriceB,
    this.productPriceC
  });

  factory Product.fromJson(Map<String, dynamic> json){
    return new Product(
      productId: json['pID'],
      productName: json['nproductMain'],
      productCode: json['pcode'],
      productNameENG: json['nproductENG'],
      productPic: json['pic'],
      productUnit1: json['unit1'],
      productUnit2: json['unit2'],
      productUnit3: json['unit3'],
      productPriceA: json['priceA'],
      productPriceB: json['priceB'],
      productPriceC: json['priceC'],
    );
  }


}