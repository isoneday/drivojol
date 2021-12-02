import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:custojol/helper/general_helper.dart';
import 'package:custojol/main.dart';
import 'package:custojol/model/history_model.dart';
import 'package:custojol/network/network.dart';
import 'package:custojol/screen/loginmysql_screen.dart';
import 'package:custojol/widget/item.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'history_screen.dart';

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(RemoteMessage message) {
  final dynamic data = message.data;
  var datax = data['datax'];
  // var datax = dataxx['datax'];
  //  var click_action = data['click_action'];
  var dataxItem = jsonDecode(datax)['datax']['data'];
  DataHistory dataBooking = DataHistory.fromJson(dataxItem);
  String? idBooking = dataBooking.idBooking;
  print("idbooking:" + idBooking!);
  // final String itemId = data['id'];
  final Item item = _items.putIfAbsent(
      idBooking,
      () => Item(
          itemId: idBooking,
          origin: dataBooking.bookingFrom,
          destination: dataBooking.bookingTujuan,
          harga: dataBooking.bookingBiayaDriver,
          jarak: dataBooking.bookingJarak,
          latcostumer: dataBooking.bookingFromLat,
          lngcostumer: dataBooking.bookingFromLng))
    ..status = jsonDecode(datax)['datax']['result'];
  return item;
}

class BerandaScreen extends StatefulWidget {
  static String id = "utama";
  @override
  _BerandaScreenState createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String? token_fcm;
  int number = 0;
  Network network = Network();
  String? iddriver, token, todayEarning, todayTrip, todayRating, device;
  static final List<String> imgSlider = [
    'gambar/ojek7.jpg',
    'gambar/ojek8.jpg',
    'gambar/ojek9.jpg',
    'gambar/ojek10.jpg',
    'gambar/ojek11.jpg',
    'gambar/ojek12.jpg',
    'gambar/ojek13.png',
    // 'gambar/ojek6.jpg',
  ];

  static final List<Widget> imageSliders = imgSlider
      .map((item) => Container(
              child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: Stack(
              children: [
                Image.asset(
                  item,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                    bottom: 10,
                    child: Container(
                      child: Text(
                        "no ${imgSlider.indexOf(item)} image",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ))
              ],
            ),
          )))
      .toList();

  bool isSwitched = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
    notification();
  }

  void notification() {
    FirebaseMessaging.instance.getToken().then((value) async {
      print("token saya :$value");
      if (token_fcm == '') {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString("tokenfcm", value!);
        // setTokentoDB(value);
      }
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        var notificationData = message.data;
        var view = notificationData["view"];
        if (view == "url") {
          // openWeb(message);
        } else {
          // Map<String, dynamic> msg = message as Map<String, dynamic>;
          showAlertDialog(context, message);
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
      if (message != null) {
        var notificationData = message.data;
        var view = notificationData["view"];
        if (view == "url") {
          // openWeb(message);
        } else {
          showAlertDialog(context, message);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      if (message != null) {
        var notificationData = message.data;
        var view = notificationData["view"];
        if (view == "url") {
          // openWeb(message);
        } else {
          showAlertDialog(context, message);
        }
      }
    });
  }

  // Future<void> openWeb(RemoteMessage message) async {
  //   bool _validUrl = Uri.parse(message.notification!.body!).isAbsolute;
  //   if (_validUrl) {
  //     await canLaunch(message.notification!.body!)
  //         ? await launch(message.notification!.body!)
  //         : throw 'Could not launch ${message.notification!.body!}';
  //   }

  void showAlertDialog(BuildContext context, RemoteMessage message) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool? shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      content: Text(
        "Item ${item.itemId} has been updated :",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30, bottom: 10, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.person_pin_circle),
                    Flexible(child: Text("Origin : " + item.origin!))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.person_pin_circle),
                    Flexible(child: Text("Destination : " + item.destination!))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Jarak : " + item.jarak!),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Harga : " + item.harga!,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(
                    child: const Text('Tolak'),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    child: const Text('Terima'),
                    onPressed: () {
                      setState(() {
                        // click = false;
                      });
                      // takeBooking(item.itemId);
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  //navigasi ke halaman detail ketika tombol (ex:show) ditekan
  void _navigateToItemDetail(RemoteMessage message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  Future<void> getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    device = await getId();
    iddriver = sharedPreferences.getString("iddriver");
    token = sharedPreferences.getString("token");
  }

  @override
  Widget build(BuildContext context) {
    //carousel slider indicator

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("gambar/inatech5.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "OFFLINE",
                style: TextStyle(
                    color: isSwitched == false ? Colors.white : Colors.black38),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                    if (isSwitched == true) {
                      print("true ya gaes");
                      statusOn();
                    } else {
                      print("faalse ya gaes");
                      statusOff();
                    }
                    print(isSwitched);
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
              Text("ONLINE",
                  style: TextStyle(
                      color:
                          isSwitched == true ? Colors.white : Colors.black38)),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.clear();
                  statusOn();
                  Navigator.popAndPushNamed(context, LoginMysqlScreen.id);
                })
          ],
        ),
        body: Column(
          children: [
            user(),
            menu(),
            slider(),
          ],
        ),
      ),
    );
  }

  user() {
    return Flexible(
        flex: 3,
        child: Container(
          // color: Colors.blue,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage("gambar/menu4.png"),
                  radius: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Iswandi Saputra",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        // border: Border.all(
                        //     // color: Colors.blue[500],
                        //     ),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "IDR",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      "450.000",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                            radius: (30),
                            backgroundColor: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                  // borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                "gambar/menu5.png",
                                color: Colors.white,
                              )),
                            )),
                        Text(
                            todayEarning != null
                                ? "💰${todayEarning}"
                                : "belum ada",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Image.asset(
                            "gambar/menu2.png",
                            color: Colors.white,
                          ),
                          // backgroundImage: AssetImage("gambar/menu2.png"),
                          radius: 30,
                        ),
                        Text(
                            todayRating != null
                                ? "⭐️${todayRating}"
                                : "belum ada",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Image.asset(
                            "gambar/menu3.png",
                            color: Colors.white,
                          ),
                          // backgroundImage: AssetImage("gambar/menu3.png"),
                          radius: 30,
                        ),
                        Text(todayTrip != null ? "🗾${todayTrip}" : "belum ada",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  menu() {
    return Flexible(
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Flexible(
                  flex: 5,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      tampilanMenu("Live Location", "gambar/driver.png",
                          Colors.blue, HistoryScreen.id),
                      SizedBox(
                        width: 10,
                      ),
                      tampilanMenu("History", "gambar/trip.png",
                          Colors.blue[200], HistoryScreen.id),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  )),
              Flexible(
                child: SizedBox(
                  height: 10,
                ),
              ),
              Flexible(
                  flex: 5,
                  child: Row(
                    children: [
                      // SizedBox(
                      //   width: 10,
                      // ),
                      // tampilanMenu("pesan ojek", "gambar/ojek.png",
                      //     Colors.blue[200], GoRideScreen.id),

                      SizedBox(
                        width: 10,
                      ),
                      tampilanMenu("My Profile", "gambar/myprofile.png",
                          Colors.blue[200], HistoryScreen.id),
                      SizedBox(
                        width: 10,
                      ),
                      tampilanMenu("My Rating", "gambar/myprofile.png",
                          Colors.blue[200], HistoryScreen.id),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }

  Widget tampilanMenu(
      String title, String gambar, Color? warna, String tujuan) {
    return Flexible(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, tujuan);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // color: warna,
          decoration: BoxDecoration(
              color: Colors.white,
              // border: Border.all(
              //     // color: Colors.blue[500],
              //     ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                gambar != null
                    ? Flexible(
                        flex: 2,
                        child: Image.asset(
                          gambar,
                          color: Colors.blue,
                        ),
                      )
                    : Image.network(""),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  slider() {
    return Flexible(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              // carousel slider
              Flexible(
                flex: 8,
                child: mySlider(),
              ),
              SizedBox(
                height: 5,
              )
              // point slider
              // Flexible(child: widgetPoint())
            ],
          ),
        ));
  }

  Widget mySlider() {
    final CarouselSlider autoPlayImage = CarouselSlider(
      options: CarouselOptions(
        height: 600,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        initialPage: 0,
        onPageChanged: (index, _) {
          setState(() {
            number = index;
          });
        },
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      ),
      items: imageSliders,
    );
    return autoPlayImage;
  }

  widgetPoint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: imgSlider.map((item) {
        int index = imgSlider.indexOf(item);
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: number == index ? Colors.black : Colors.pink),
        );
      }).toList(),
    );
  }

  void statusOn() {
    network.statusOn(iddriver, token, device).then((response) async {
      if (response?.result == "true") {
        Toast.show(response?.msg, context);
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setBool("status", true);
      } else {
        Toast.show(response?.msg, context);
      }
    });
  }

  void statusOff() {
    network.statusOff(iddriver, token, device).then((response) async {
      if (response?.result == "true") {
        Toast.show(response?.msg, context);
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setBool("status", false);
      } else {
        Toast.show(response?.msg, context);
      }
    });
  }
}
