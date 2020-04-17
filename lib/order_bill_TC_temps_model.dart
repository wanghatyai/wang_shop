class OrderBillTCTemps{
  final String orderBillTCID;
  final String orderBillTCCode;
  final String orderBillTCCus;
  final String orderBillTCPpic;
  final String orderBillTCPcode;
  final String orderBillTCPname;
  final String orderBillTCPq;
  final String orderBillTCPunit;
  final String orderBillTCPprice;
  final String orderBillTCPsumPrice;
  final String orderBillTCDateAdd;

  OrderBillTCTemps({
    this.orderBillTCID,
    this.orderBillTCCode,
    this.orderBillTCCus,
    this.orderBillTCPpic,
    this.orderBillTCPcode,
    this.orderBillTCPname,
    this.orderBillTCPq,
    this.orderBillTCPunit,
    this.orderBillTCPprice,
    this.orderBillTCPsumPrice,
    this.orderBillTCDateAdd
  });

  factory OrderBillTCTemps.fromJson(Map<String, dynamic> json){
    return new OrderBillTCTemps(
      orderBillTCID: json['orderBill_TC_ID'],
      orderBillTCCode: json['orderBill_TC_Code'],
      orderBillTCCus: json['orderBill_TC_Cus'],
      orderBillTCPpic: json['pic'],
      orderBillTCPcode: json['orderBill_TC_Pcode'],
      orderBillTCPname: json['orderBill_TC_Pname'],
      orderBillTCPq: json['orderBill_TC_Pq'],
      orderBillTCPunit: json['orderBill_TC_Punit'],
      orderBillTCPprice: json['orderBill_TC_Pprice'],
      orderBillTCPsumPrice: json['orderBill_TC_PsumPrice'],
      orderBillTCDateAdd: json['orderBill_TC_DateA'],
    );
  }
}