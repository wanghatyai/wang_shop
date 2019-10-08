class Member{
  final String memberId;
  final String memberCode;
  final String memberName;
  final String memberCredit;
  final String memberAddress;

  Member({
    this.memberId,
    this.memberCode,
    this.memberName,
    this.memberCredit,
    this.memberAddress
  });

  factory Member.fromJson(Map<String, dynamic> json){
    return new Member(
      memberId: json['id_user'],
      memberCode: json['ccode'],
      memberName: json['name'],
      memberCredit: json['credit'],
      memberAddress: json['address'],
    );
  }
}