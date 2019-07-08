import 'package:flutter/material.dart';

class Product{
  final String productId;
  final String productName;
  final String productCode;
  final String productBarcode;
  final String productNameENG;
  final String productPic;
  final String productUnit1;
  final String productUnitQty1;
  final String productUnit2;
  final String productUnitQty2;
  final String productUnit3;
  final String productUnitQty3;
  final String productPriceA;
  final String productPriceB;
  final String productPriceC;
  final String productFreePrice;
  final String productProStatus;
  final String productProLimit;


  Product({
    this.productId,
    this.productName,
    this.productCode,
    this.productBarcode,
    this.productNameENG,
    this.productPic,
    this.productUnit1,
    this.productUnitQty1,
    this.productUnit2,
    this.productUnitQty2,
    this.productUnit3,
    this.productUnitQty3,
    this.productPriceA,
    this.productPriceB,
    this.productPriceC,
    this.productFreePrice,
    this.productProStatus,
    this.productProLimit
  });

  factory Product.fromJson(Map<String, dynamic> json){
    return new Product(
      productId: json['pID'],
      productName: json['nproductMain'],
      productCode: json['pcode'],
      productBarcode: json['bcode'],
      productNameENG: json['nproductENG'],
      productPic: json['pic'],
      productUnit1: json['unit1'],
      productUnitQty1: json['unitQty1'],
      productUnit2: json['unit2'],
      productUnitQty2: json['unitQty2'],
      productUnit3: json['unit3'],
      productUnitQty3: json['unitQty3'],
      productPriceA: json['priceA'],
      productPriceB: json['priceB'],
      productPriceC: json['priceC'],
      productFreePrice: json['freePrice'],
      productProStatus: json['stype'],
      productProLimit: json['limit1'],
    );
  }


}