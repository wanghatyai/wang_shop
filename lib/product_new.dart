import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ProductNewPage extends StatefulWidget {
  @override
  _ProductNewPageState createState() => _ProductNewPageState();
}

class _ProductNewPageState extends State<ProductNewPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('New'),);
  }
}
