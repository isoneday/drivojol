import 'package:custojol/argument/detail_argumen.dart';
import 'package:custojol/model/history_model.dart';
import 'package:custojol/screen/detailhistory_screen.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class HistoryItem extends StatefulWidget {
  DataHistory? dataHistory;

  HistoryItem({Key? key, this.dataHistory}) : super(key: key);

  @override
  State<HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Toast.show(widget.dataHistory?.idBooking, context);
        Navigator.pushNamed(context, DetailHistoryScreen.id,
                arguments: DetailArgumen(
                    widget.dataHistory?.bookingFrom,
                    widget.dataHistory?.bookingTujuan,
                    widget.dataHistory?.bookingJarak,
                    widget.dataHistory?.bookingBiayaUser,
                    widget.dataHistory?.idBooking))
            .then((value) {
          setState(() {});
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Card(
          elevation: 7,
          child: Column(
            children: [
              Container(
                color: Colors.blue,
                height: 30,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      widget.dataHistory?.bookingTanggal ?? "tdk ada tnggl",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8, left: 8),
                child: Row(
                  children: [
                    Icon(Icons.person_pin),
                    Flexible(
                        child: Text(
                      widget.dataHistory?.bookingFrom ?? "-",
                      style: TextStyle(fontSize: 12),
                    ))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8, left: 8, top: 5),
                child: Row(
                  children: [
                    Icon(Icons.person_pin),
                    Flexible(
                        child: Text(widget.dataHistory?.bookingTujuan ?? "-",
                            style: TextStyle(fontSize: 12)))
                  ],
                ),
              ),
              Divider(
                color: Colors.black38,
              ),
              Container(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: Text(
                      "BIAYA : " + widget.dataHistory!.bookingBiayaUser!,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
