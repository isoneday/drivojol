 
import 'package:custojol/model/history_model.dart';
import 'package:flutter/material.dart';

import 'history_item.dart';

class History extends StatelessWidget {
  List<DataHistory>? dataHistory;
  History({Key? key, this.dataHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dataHistory?.length ?? 0,
      itemBuilder: (context, index) => HistoryItem(
        dataHistory: dataHistory?[index],
      ),
    );
  }
}
