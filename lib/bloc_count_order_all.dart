import 'dart:async';
import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/database_helper.dart';

class BlocCountOrderAll implements BlocBase{

  //int counter;
  var countOrderAll = 0;
  StreamController counterAllStreamController = StreamController();

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  @override
  void dispose() {
    // TODO: implement dispose
    counterAllStreamController.close();
  }

  getOrderAllCount() async{
    var resCountOrder = await databaseHelper.countOrder();
    countOrderAll = resCountOrder[0]['countOrderAll'];
    //counter = counter + value;
    counterAllStreamController.sink.add(countOrderAll);
  }

}