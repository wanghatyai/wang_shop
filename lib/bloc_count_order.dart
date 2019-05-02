import 'dart:async';
import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/database_helper.dart';

class BlocCountOrder implements BlocBase{

  //int counter;
  var countOrderAll;
  StreamController counterStreamController = StreamController();

  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  BlocCountOrder() {
    //counter = 0;
    countOrderAll = 0;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    counterStreamController.close();
  }

  getOrderCount() async{
    var resCountOrder = await databaseHelper.countOrder();
    countOrderAll = resCountOrder[0]['countOrderAll'];
    //counter = counter + value;
    counterStreamController.sink.add(countOrderAll);
  }

}