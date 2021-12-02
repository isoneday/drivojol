import 'dart:convert';

import 'package:custojol/model/auth_model.dart';
import 'package:custojol/model/detaildriver_model.dart';
import 'package:custojol/model/history_model.dart';
import 'package:custojol/model/insertbooking_model.dart';
import 'package:custojol/model/waitingdriver_model.dart';
import 'package:http/http.dart' as http;

class Network {
  static String _host = "udakita.com";
  Future<ModelAuth?> registerUser(
      String? email, String? password, String? nama, String? phone) async {
    final endpoint = Uri.http(_host, "serverojol/api/daftar/3");
    final response = await http.post(endpoint, body: {
      "email": email,
      "password": password,
      "nama": nama,
      "phone": phone
    });

    if (response.statusCode == 200) {
      ModelAuth auth = ModelAuth.fromJson(jsonDecode(response.body));
      return auth;
    } else {
      return null;
    }
  }

  Future<ModelAuth?> loginUser(
      String? email, String? password, String? device) async {
    final endpoint = Uri.http(_host, "serverojol/api/login_driver");
    final response = await http.post(endpoint,
        body: {"f_email": email, "f_password": password, "device": device});
    if (response.statusCode == 200) {
      ModelAuth auth = ModelAuth.fromJson(jsonDecode(response.body));
      return auth;
    } else {
      return null;
    }
  }

  Future<ModelDetailDriver?> detailDriver(
    String? idDriver,
  ) async {
    final endpoint = Uri.http(_host, "serverojol/api/get_driver");
    final response = await http.post(endpoint, body: {"f_iddriver": idDriver});
    if (response.statusCode == 200) {
      ModelDetailDriver auth =
          ModelDetailDriver.fromJson(jsonDecode(response.body));
      return auth;
    } else {
      return null;
    }
  }

  Future<ModelHistory?> history(
    String? iduser,
    String? status,
    String? token,
    String? device,
  ) async {
    final endpoint = Uri.http(_host, "serverojol/api/get_booking");
    final response = await http.post(endpoint, body: {
      "f_idUser": iduser,
      "status": status,
      "f_token": token,
      "f_device": device
    });
    if (response.statusCode == 200) {
      ModelHistory auth = ModelHistory.fromJson(jsonDecode(response.body));
      return auth;
    } else {
      return null;
    }
  }

  Future<ModelHistory?> completeBooking(
    String? iduser,
    String? idbooking,
    String? token,
    String? device,
  ) async {
    final endpoint =
        Uri.http(_host, "serverojol/api/complete_booking_from_user");
    final response = await http.post(endpoint, body: {
      "f_idUser": iduser,
      "id": idbooking,
      "f_token": token,
      "f_device": device
    });
    if (response.statusCode == 200) {
      ModelHistory auth = ModelHistory.fromJson(jsonDecode(response.body));
      return auth;
    } else {
      return null;
    }
  }

  Future<ModelHistory?> statusOff(
    String? iddriver,
    String? token,
    String? device,
  ) async {
    final endpoint = Uri.http(_host, "serverojol/api/change_statusOff");
    final response = await http.post(endpoint,
        body: {"iddriver": iddriver, "f_token": token, "f_device": device});
    if (response.statusCode == 200) {
      ModelHistory auth = ModelHistory.fromJson(jsonDecode(response.body));
      return auth;
    } else {
      return null;
    }
  }

  Future<ModelHistory?> statusOn(
    String? iddriver,
    String? token,
    String? device,
  ) async {
    final endpoint = Uri.http(_host, "serverojol/api/change_statusOn");
    final response = await http.post(endpoint,
        body: {"iddriver": iddriver, "f_token": token, "f_device": device});
    if (response.statusCode == 200) {
      ModelHistory auth = ModelHistory.fromJson(jsonDecode(response.body));
      return auth;
    } else {
      return null;
    }
  }
}
