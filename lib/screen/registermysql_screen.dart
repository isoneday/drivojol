import 'package:custojol/helper/rounded_button.dart';
import 'package:custojol/network/network.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'loginmysql_screen.dart';

class RegisterMysqlSCreen extends StatefulWidget {
  static String id = "registermysql";
  const RegisterMysqlSCreen({Key? key}) : super(key: key);

  @override
  _RegisterMysqlSCreenState createState() => _RegisterMysqlSCreenState();
}

class _RegisterMysqlSCreenState extends State<RegisterMysqlSCreen> {
  String? email, password, nama, phone;
  bool? loading;
  Network network = Network();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
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
              TextField(
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  nama = value;
                },
                decoration: InputDecoration(hintText: "nama"),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.phone,
                obscureText: true,
                decoration: InputDecoration(hintText: "phone"),
                onChanged: (value) {
                  phone = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              RoundedButton(
                text: "Register",
                color: Colors.blue[700],
                callback: () {
                  prosesRegister();
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

  Future<void> prosesRegister() async {
    loading = true;
    network.registerUser(email, password, nama, phone).then((response) {
      if (response?.result == "true") {
        Toast.show(response?.msg, context);
        Navigator.popAndPushNamed(context, LoginMysqlScreen.id);
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
            content: Text("Gagal Register: ${response?.msg}"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
