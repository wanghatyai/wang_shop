import 'dart:async';
import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/database_helper.dart';

class BlocCountOrder implements BlocBase{

  //int counter;
  var countOrder;
  var countOrderAll;

  StreamController streamCounterController = StreamController.broadcast();

  Sink get counterSink => streamCounterController.sink;

  Stream get counterStream => streamCounterController.stream;

  DatabaseHelper databaseHelper = DatabaseHelper.internal();


  BlocCountOrder(){
    countOrder = '';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    streamCounterController.close();
  }


  getOrderCount() async{
    var resCountOrder = await databaseHelper.countOrder();
    countOrder = resCountOrder[0]['countOrderAll'];
    //print(addOrderCount());
    //countOrderVal = addOrderCount();
    print(countOrder);
    counterSink.add(countOrder);
  }

  clearOrderCount(){
    countOrder = '';
    counterSink.add(countOrder);
  }

  /*addOrderCount() async{
    var resCountOrder = await databaseHelper.countOrder();
    countOrder = resCountOrder[0]['countOrderAll'];
    print(countOrder);
    //return countOrder;
  }*/

}