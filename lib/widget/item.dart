import 'dart:async';

import 'package:custojol/screen/detaildriver_screen.dart';
import 'package:flutter/material.dart';

class Item {
  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;
  String? origin, destination, harga, jarak, latcostumer, lngcostumer;
  String? _status;
  String? get status => _status;
  final String? itemId;

  Item(
      {this.itemId,
      this.origin,
      this.destination,
      this.harga,
      this.jarak,
      this.latcostumer,
      this.lngcostumer});

  set status(String? value) {
    _status = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$itemId';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailDriverScreen(),
      ),
    );
  }
}
