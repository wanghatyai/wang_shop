import 'package:flutter/material.dart';

class Product{
  String productId;
  String productName;
  String productCode;
  String productNameENG;
  String productPic;

  Product(
    this.productId,
    this.productName,
    this.productCode,
    this.productNameENG,
    this.productPic,
  );

  Product.fromJson(Map<String, dynamic> json)
    :
        productId =  json['id'],
        productName = json['nproductMain'],
        productCode = json['pcode'],
        productNameENG = json['nproductENG'],
        productPic = json['pic'];

  Map<String, dynamic> toJson() => {
        'productId' : productId,
        'productName' : productName,
        'productCode' : productCode,
        'productNameENG' : productNameENG,
        'productPic' : productNameENG,
  };


}