class OrderBillTemps{
  final String orderBillID;
  final String orderBillCode;
  final String orderBillCus;
  final String orderBillSentStatus;

  OrderBillTemps({
    this.orderBillID,
    this.orderBillCode,
    this.orderBillCus,
    this.orderBillSentStatus
  });

  factory OrderBillTemps.fromJson(Map<String, dynamic> json){
    return new OrderBillTemps(
      orderBillID: json['orderBill_ID'],
      orderBillCode: json['orderBill_Code'],
      orderBillCus: json['orderBill_Cus'],
      orderBillSentStatus: json['sent_status'],
    );
  }

}