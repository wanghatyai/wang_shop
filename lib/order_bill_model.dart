class OrderBill{
  final String orderBillId;
  final String orderBillDate;
  final String orderBillTime;
  final String orderBillCode;
  final String orderBillStatus;
  final String orderBillDateST;
  final String orderBillTimeST;


  OrderBill({
    this.orderBillId,
    this.orderBillDate,
    this.orderBillTime,
    this.orderBillCode,
    this.orderBillStatus,
    this.orderBillDateST,
    this.orderBillTimeST
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
    );
  }

}