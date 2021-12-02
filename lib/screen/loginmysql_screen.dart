import 'package:custojol/helper/general_helper.dart';
import 'package:custojol/helper/rounded_button.dart';
import 'package:custojol/network/network.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'beranda_screen.dart';

class LoginMysqlScreen extends StatefulWidget {
  static String id = "mysqllogin";
  const LoginMysqlScreen({Key? key}) : super(key: key);

  @override
  _LoginMysqlScreenState createState() => _LoginMysqlScreenState();
}

class _LoginMysqlScreenState extends State<LoginMysqlScreen> {
  String? email, password, nama, phone;
  bool? loading;
  Network network = Network();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("login"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(hintText: "email"),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(hintText: "password"),
                onChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              RoundedButton(
                text: "Login",
                color: Colors.blue[700],
                callback: () {
                  prosesLogin();
                },
              ),
              loading == true
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Future<void> prosesLogin() async {
    loading = true;
    String device = await getId();

    network.loginUser(email, password, device).then((response) async {
      if (response?.result == "true") {
        Toast.show(response?.msg, context);
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setBool("sesi", true);
        sharedPreferences.setString("iddriver", response!.data!.idUser!);
        sharedPreferences.setString("token", response.token!);
        sharedPreferences.setString("tokenfcm", response.data?.userGcm ?? "");

        sharedPreferences.setString("email", response.data!.userEmail!);

        Navigator.popAndPushNamed(context, BerandaScreen.id);
        setState(() {
          loading = false;
        });
      } else {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal Login: ${response?.msg}"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
