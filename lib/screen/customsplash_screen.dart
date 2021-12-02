import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_screen.dart';
import 'beranda_screen.dart';

class CustomSplashScreen extends StatefulWidget {
  static String id = "splash";

  const CustomSplashScreen({Key? key}) : super(key: key);

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  Timer? timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cekKondisi();
  }

  cekKondisi() {
    var duration = Duration(seconds: 4);
    return Timer(duration, () async {
      //untuk pemindahan halaman
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool sesi = prefs.getBool("sesi") ?? false;
      if (sesi) {
        Navigator.pushReplacementNamed(context, BerandaScreen.id);
      } else {
        Navigator.pushReplacementNamed(context, AuthScreen.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Aplikasi OJOL Costumer",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Image.network(
              "https://smart-fl.bankkalsel.co.id/assets/images/logo.png",
            ),
            SizedBox(
              height: 150,
            ),
            CircularProgressIndicator(),
            SizedBox(
              height: 40,
            ),
            Text("Loading.....")
          ],
        ),
      ),
    );
  }
}
