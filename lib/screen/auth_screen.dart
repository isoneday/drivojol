import 'package:custojol/helper/rounded_button.dart';
import 'package:flutter/material.dart';

import 'loginmysql_screen.dart';
import 'registermysql_screen.dart';

class AuthScreen extends StatelessWidget {
  static String id = "auth";

  AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Authentication"),
      ),
      body: Center(
        child: Column(
          children: [
            RoundedButton(
              color: Colors.blue[700],
              text: "Login by MySql",
              callback: () {
                Navigator.pushNamed(context, LoginMysqlScreen.id);
              },
            ),
            SizedBox(
              height: 20,
            ),
            RoundedButton(
              color: Colors.blue[700],
              text: "Register by MySql",
              callback: () {
                Navigator.pushNamed(context, RegisterMysqlSCreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
