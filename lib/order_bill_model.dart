class OrderBill{
  final String orderBillId;
  final String orderBillDate;
  final String orderBillTime;
  final String orderBillCode;
  final String orderBillStatus;
  final String orderBillDateST;
  final String orderBillTimeST;
  final String orderBillProductCode;
  final String orderBillProductName;
  final String orderBillProductUnit1;
  final String orderBillProductUnit2;
  final String orderBillProductUnit3;
  final String orderBillProductPrice11;
  final String orderBillProductPrice12;
  final String orderBillProductPrice13;
  final String orderBillProductPrice21;
  final String orderBillProductPrice22;
  final String orderBillProductPrice23;
  final String orderBillProductPrice31;
  final String orderBillProductPrice32;
  final String orderBillProductPrice33;
  final String orderBillProductSelectUnit;
  final String orderBillProductSelectQty;
  final String orderBillProductSelectPrice;


  OrderBill({
    this.orderBillId,
    this.orderBillDate,
    this.orderBillTime,
    this.orderBillCode,
    this.orderBillStatus,
    this.orderBillDateST,
    this.orderBillTimeST,
    this.orderBillProductCode,
    this.orderBillProductName,
    this.orderBillProductUnit1,
    this.orderBillProductUnit2,
    this.orderBillProductUnit3,
    this.orderBillProductPrice11,
    this.orderBillProductPrice12,
    this.orderBillProductPrice13,
    this.orderBillProductPrice21,
    this.orderBillProductPrice22,
    this.orderBillProductPrice23,
    this.orderBillProductPrice31,
    this.orderBillProductPrice32,
    this.orderBillProductPrice33,
    this.orderBillProductSelectUnit,
    this.orderBillProductSelectQty,
    this.orderBillProductSelectPrice
  });

  factory OrderBill.fromJson(Map<String, dynamic> json){
    return new OrderBill(
      orderBillId: json['id'],
      orderBillDate: json['om_date'],
      orderBillTime: json['om_time'],
      orderBillCode: json['code'],
      orderBillStatus: json['status'],
      orderBillDateST: json['date'],
      orderBillTimeST: json['time'],
      orderBillProductCode: json['pcode'],
      orderBillProductName: json['nproduct'],
      orderBillProductUnit1: json['unit1'],
      orderBillProductUnit2: json['unit2'],
      orderBillProductUnit3: json['unit3'],
      orderBillProductPrice11: json['p11'],
      orderBillProductPrice12: json['p12'],
      orderBillProductPrice13: json['p13'],
      orderBillProductPrice21: json['p21'],
      orderBillProductPrice22: json['p22'],
      orderBillProductPrice23: json['p23'],
      orderBillProductPrice31: json['p31'],
      orderBillProductPrice32: json['p32'],
      orderBillProductPrice33: json['p33'],
      orderBillProductSelectUnit: json['type'],
      orderBillProductSelectQty: json['pno'],
      orderBillProductSelectPrice: json['price'],
    );
  }

}