class OrderBill{
  final String orderBillMainId;
  final String orderBillId;
  final String orderBillDate;
  final String orderBillTime;
  final String orderBillCode;
  final String orderBillStatus;
  final String orderBillDateST;
  final String orderBillTimeST;
  final String orderBillProductCode;
  final String orderBillProductName;
  final String orderBillProductPic;
  final String orderBillProductUnit1;
  final String orderBillProductUnitQty1;
  final String orderBillProductUnit2;
  final String orderBillProductUnitQty2;
  final String orderBillProductUnit3;
  final String orderBillProductUnitQty3;
  final String orderBillProductPriceA;
  final String orderBillProductPriceB;
  final String orderBillProductPriceC;
  final String orderBillProductProStatus;
  final String orderBillProductSelectUnit;
  final String orderBillProductSelectQty;
  final String orderBillProductSelectPrice;


  OrderBill({
    this.orderBillMainId,
    this.orderBillId,
    this.orderBillDate,
    this.orderBillTime,
    this.orderBillCode,
    this.orderBillStatus,
    this.orderBillDateST,
    this.orderBillTimeST,
    this.orderBillProductCode,
    this.orderBillProductName,
    this.orderBillProductPic,
    this.orderBillProductUnit1,
    this.orderBillProductUnitQty1,
    this.orderBillProductUnit2,
    this.orderBillProductUnitQty2,
    this.orderBillProductUnit3,
    this.orderBillProductUnitQty3,
    this.orderBillProductPriceA,
    this.orderBillProductPriceB,
    this.orderBillProductPriceC,
    this.orderBillProductProStatus,
    this.orderBillProductSelectUnit,
    this.orderBillProductSelectQty,
    this.orderBillProductSelectPrice
  });

  factory OrderBill.fromJson(Map<String, dynamic> json){
    return new OrderBill(
      orderBillMainId: json['om_id'],
      orderBillId: json['id'],
      orderBillDate: json['om_date'],
      orderBillTime: json['om_time'],
      orderBillCode: json['code'],
      orderBillStatus: json['status'],
      orderBillDateST: json['date'],
      orderBillTimeST: json['time'],
      orderBillProductCode: json['pcode'],
      orderBillProductName: json['nproduct'],
      orderBillProductPic: json['pic'],
      orderBillProductUnit1: json['unit1'],
      orderBillProductUnitQty1: json['unitQty1'],
      orderBillProductUnit2: json['unit2'],
      orderBillProductUnitQty2: json['unitQty2'],
      orderBillProductUnit3: json['unit3'],
      orderBillProductUnitQty3: json['unitQty3'],
      orderBillProductPriceA: json['priceA'],
      orderBillProductPriceB: json['priceB'],
      orderBillProductPriceC: json['priceC'],
      orderBillProductProStatus: json['stype'],
      orderBillProductSelectUnit: json['type'],
      orderBillProductSelectQty: json['pno'],
      orderBillProductSelectPrice: json['price'],
    );
  }

}