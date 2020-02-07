class Overdue {
  final String CBS_ID;
  final String CBS_Pricegroup;
  final String CBS_PCash;
  final String CBS_Number;
  final String CBS_Date_Receive;
  final String CBS_Cuscode;
  final String CBS_Cusroute;
  final String CBS_Cusname;
  final String CBS_Price_Bill;
  final String CBS_Price_Payments;
  final String CBS_Price_Balance;
  final String CBS_Date_Upload;
  final String CBS_Status_Print;
  final String CBS_Emp_Print;
  final String CBS_Date_Print;
  final String CBS_Logistic;
  final String CBS_DateScan_S;
  final String CBS_Note;
  final String CBS_Status;
  final String CBS_recount;
  final String cbs_linesent;
  final String CBS_Datesent;
  final String CBS_Daydue;

  Overdue({
    this.CBS_ID,
    this.CBS_Pricegroup,
    this.CBS_PCash,
    this.CBS_Number,
    this.CBS_Date_Receive,
    this.CBS_Cuscode,
    this.CBS_Cusroute,
    this.CBS_Cusname,
    this.CBS_Price_Bill,
    this.CBS_Price_Payments,
    this.CBS_Price_Balance,
    this.CBS_Date_Upload,
    this.CBS_Status_Print,
    this.CBS_Emp_Print,
    this.CBS_Date_Print,
    this.CBS_Logistic,
    this.CBS_DateScan_S,
    this.CBS_Note,
    this.CBS_Status,
    this.CBS_recount,
    this.cbs_linesent,
    this.CBS_Datesent,
    this.CBS_Daydue

  });

  factory Overdue.fromJson(Map<String, dynamic> json) {
    return Overdue(
      CBS_ID: json['CBS_ID'] as String,
      CBS_Pricegroup: json['CBS_Pricegroup'] as String,
      CBS_PCash: json['CBS_PCash'] as String,
      CBS_Number: json['CBS_Number'] as String,
      CBS_Date_Receive: json['CBS_Date_Receive'] as String,
      CBS_Cuscode: json['CBS_Cuscode'] as String,
      CBS_Cusroute: json['CBS_Cusroute'] as String,
      CBS_Cusname: json['CBS_Cusname'] as String,
      CBS_Price_Bill: json['CBS_Price_Bill'] as String,
      CBS_Price_Payments: json['CBS_Price_Payments'] as String,
      CBS_Price_Balance: json['CBS_Price_Balance'] as String,
      CBS_Date_Upload: json['CBS_Date_Upload'] as String,
      CBS_Status_Print: json['CBS_Status_Print'] as String,
      CBS_Emp_Print: json['CBS_Emp_Print'] as String,
      CBS_Date_Print: json['CBS_Date_Print'] as String,
      CBS_Logistic: json['CBS_Logistic'] as String,
      CBS_DateScan_S: json['CBS_DateScan_S'] as String,
      CBS_Note: json['CBS_Note'] as String,
      CBS_Status: json['CBS_Status'] as String,
      CBS_recount: json['CBS_recount'] as String,
      cbs_linesent: json['cbs_linesent'] as String,
      CBS_Datesent: json['CBS_Datesent'] as String,
      CBS_Daydue: json['CBS_Daydue'] as String,
    );
  }
}