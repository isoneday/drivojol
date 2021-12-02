import 'package:custojol/helper/general_helper.dart';
import 'package:custojol/helper/rounded_button.dart';
import 'package:custojol/model/history_model.dart';
import 'package:custojol/network/network.dart';
import 'package:custojol/screen/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class DetailHistoryScreen extends StatefulWidget {
  static String id = "detailhistory";
  String? bookingFrom;
  String? bookingTujuan;
  String? bookingJarak;
  String? bookingBiayaUser;
  String? idbooking;
  DetailHistoryScreen(
      {Key? key,
      this.bookingFrom,
      this.bookingTujuan,
      this.bookingJarak,
      this.bookingBiayaUser,
      this.idbooking})
      : super(key: key);

  @override
  _DetailHistoryScreenState createState() => _DetailHistoryScreenState();
}

class _DetailHistoryScreenState extends State<DetailHistoryScreen> {
  Network network = Network();

  String? iduser;

  String? device;

  String? token;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  Future<void> getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    device = await getId();
    iduser = sharedPreferences.getString("iduser");
    token = sharedPreferences.getString("token");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail History"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("From :${widget.bookingFrom}"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Destination : ${widget.bookingTujuan}"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("distance : ${widget.bookingJarak}"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("price : ${widget.bookingBiayaUser ?? "3232"}"),
          ),
          Center(
            child: RoundedButton(
              color: Colors.blue,
              text: "Complete Booking",
              callback: () {
                completeBooking();
              },
            ),
          )
        ],
      ),
    );
  }

  void completeBooking() {
    network
        .completeBooking(iduser, widget.idbooking, token, device)
        .then((response) {
      if (response?.result == "true") {
        Toast.show(response?.msg, context);
        Navigator.pop(context, true);
      } else {
        Toast.show(response?.msg, context);
      }
    });
  }
}
