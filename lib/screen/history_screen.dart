import 'package:custojol/helper/general_helper.dart';
import 'package:custojol/model/history_model.dart';
import 'package:custojol/network/network.dart';
import 'package:custojol/widget/history.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  static String id = "history";
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  String? device;

  String? iduser;

  String? token;
  Network network = Network();
  TabController? controller;

  List<DataHistory>? dataHistory = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller!.addListener(() {
      setState(() {
        switch (controller?.index) {
          case 0:
            return getHistory("2");

            break;
          case 1:
            return getHistory("4");

            break;
          case 2:
            return getHistory("3");

            break;
          default:
        }
      });
    });
    getPref();
  }

  Future<void> getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    device = await getId();
    iduser = sharedPreferences.getString("iduser");
    token = sharedPreferences.getString("token");
    getHistory("2");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("history"),
        backgroundColor: Colors.blue,
        bottom: TabBar(
            indicatorColor: Colors.yellow[900],
            controller: controller,
            tabs: [
              Tab(
                text: "progress",
              ),
              Tab(
                text: "complete",
              ),
              Tab(
                text: "cancel",
              ),
            ]),
      ),
      body: TabBarView(controller: controller, children: [
        RefreshIndicator(
            child: Container(
              margin: EdgeInsets.all(10),
              child: History(
                dataHistory: dataHistory,
              ),
            ),
            onRefresh: () => getHistory("2")),
        RefreshIndicator(
            child: Container(
              margin: EdgeInsets.all(10),
              child: History(dataHistory: dataHistory),
            ),
            onRefresh: () => getHistory("4")),
        RefreshIndicator(
            child: Container(
              margin: EdgeInsets.all(10),
              child: History(dataHistory: dataHistory),
            ),
            onRefresh: () => getHistory("3")),
      ]),
    );
  }

  getHistory(String status) async {
    return network.history(iduser, status, token, device).then((response) {
      if (response?.result == "true") {
        setState(() {
          dataHistory = response?.data;
        });
      } else {
        print("tiddak ada data");
        setState(() {
          dataHistory = [];
        });
      }
    });
  }
}
