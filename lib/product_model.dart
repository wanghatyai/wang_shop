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
  final String productP11;
  final String productP12;
  final String productP21;
  final String productP22;
  final String productP31;
  final String productP32;


  Product({
    this.productId,
    this.productName,
    this.productCode,
    this.productNameENG,
    this.productPic,
    this.productUnit1,
    this.productUnit2,
    this.productUnit3,
    this.productP11,
    this.productP12,
    this.productP21,
    this.productP22,
    this.productP31,
    this.productP32
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
      productP11: json['p11'],
      productP12: json['p12'],
      productP21: json['p21'],
      productP22: json['p22'],
      productP31: json['p31'],
      productP32: json['p32'],
    );
  }


}