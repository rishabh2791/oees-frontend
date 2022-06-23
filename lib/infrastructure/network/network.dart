import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/utilities/headers.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/middlewares/refresh_token.dart';

NetworkAPIProvider networkAPIProvider = NetworkAPIProvider();

class NetworkAPIProvider {
  Future<Map<String, dynamic>> get(String url, TokenType tokenType) async {
    var responseJSON = <String, dynamic>{};
    var uri = Uri.parse(baseURL + url);
    DateTime now = DateTime.now();

    try {
      isLoadingServerData = true;
      int secondsToExpiry = accessTokenExpiryTime.difference(now).inSeconds;
      if (secondsToExpiry < 2 && isLoggedIn && !isRefreshing) {
        await Future.forEach(
            ([
              await refreshAccessToken(),
            ]), (value) async {
          await http.get(uri, headers: getHeader(tokenType)).then((response) {
            isLoadingServerData = false;
            responseJSON = json.decode(response.body.toString());
          });
        });
      } else {
        await http.get(uri, headers: getHeader(tokenType)).then((response) {
          isLoadingServerData = false;
          responseJSON = json.decode(response.body.toString());
        });
      }
    } on SocketException {
      responseJSON = {"error": "Socket Exception"};
    } on FormatException {
      responseJSON = {"error": "Format Exception"};
    } on HttpException {
      responseJSON = {"error": "HTTP Exception"};
    }
    return responseJSON;
  }

  Future<Map<String, dynamic>> post(String url, dynamic payload, TokenType tokenType) async {
    var responseJSON = <String, dynamic>{};
    DateTime now = DateTime.now();
    var uri = Uri.parse(baseURL + url);

    try {
      isLoadingServerData = true;
      int secondsToExpiry = accessTokenExpiryTime.difference(now).inSeconds;
      if (secondsToExpiry < 2 && isLoggedIn && !isRefreshing) {
        await Future.forEach(
            ([
              await refreshAccessToken(),
            ]), (value) async {
          await http.post(uri, headers: getHeader(tokenType), body: json.encode(payload)).then((response) {
            isLoadingServerData = false;
            responseJSON = json.decode(response.body.toString());
          });
        });
      } else {
        await http.post(uri, headers: getHeader(tokenType), body: json.encode(payload)).then((response) {
          isLoadingServerData = false;
          responseJSON = json.decode(response.body.toString());
        });
      }
    } on Exception {
      responseJSON = {"error": "Network Exception"};
    }
    return responseJSON;
  }

  Future<Map<String, dynamic>> patch(String url, Map<String, dynamic> payload, TokenType tokenType) async {
    var responseJSON = <String, dynamic>{};
    var uri = Uri.parse(baseURL + url);
    DateTime now = DateTime.now();

    try {
      isLoadingServerData = true;
      int secondsToExpiry = accessTokenExpiryTime.difference(now).inSeconds;
      if (secondsToExpiry < 2 && isLoggedIn && !isRefreshing) {
        await Future.forEach(
            ([
              await refreshAccessToken(),
            ]), (value) async {
          await http.patch(uri, headers: getHeader(tokenType), body: json.encode(payload)).then((response) {
            isLoadingServerData = false;
            responseJSON = json.decode(response.body.toString());
          });
        });
      } else {
        await http.patch(uri, headers: getHeader(tokenType), body: json.encode(payload)).then((response) {
          isLoadingServerData = false;
          responseJSON = json.decode(response.body.toString());
        });
      }
    } on Exception {
      responseJSON = {"error": "Network Exception"};
    }
    return responseJSON;
  }

  Future<Map<String, dynamic>> put(String url, Map<String, dynamic> payload, TokenType tokenType) async {
    var responseJSON = <String, dynamic>{};
    var uri = Uri.parse(baseURL + url);
    DateTime now = DateTime.now();

    try {
      isLoadingServerData = true;
      int secondsToExpiry = accessTokenExpiryTime.difference(now).inSeconds;
      if (secondsToExpiry < 2 && isLoggedIn && !isRefreshing) {
        await Future.forEach(
            ([
              await refreshAccessToken(),
            ]), (value) async {
          await http.put(uri, headers: getHeader(tokenType), body: json.encode(payload)).then((response) {
            isLoadingServerData = false;
            responseJSON = json.decode(response.body.toString());
          });
        });
      } else {
        await http.put(uri, headers: getHeader(tokenType), body: json.encode(payload)).then((response) {
          isLoadingServerData = false;
          responseJSON = json.decode(response.body.toString());
        });
      }
    } on Exception {
      responseJSON = {"error": "Network Exception"};
    }
    return responseJSON;
  }

  Future<Map<String, dynamic>> delete(String url, String id, TokenType tokenType) async {
    var responseJSON = <String, dynamic>{};
    var uri = Uri.parse(baseURL + url);
    DateTime now = DateTime.now();

    try {
      isLoadingServerData = true;
      int secondsToExpiry = accessTokenExpiryTime.difference(now).inSeconds;
      if (secondsToExpiry < 2 && isLoggedIn && !isRefreshing) {
        await Future.forEach(
            ([
              await refreshAccessToken(),
            ]), (value) async {
          await http.delete(uri, headers: getHeader(tokenType)).then((response) {
            isLoadingServerData = false;
            responseJSON = json.decode(response.body.toString());
          });
        });
      } else {
        await http.delete(uri, headers: getHeader(tokenType)).then((response) {
          isLoadingServerData = false;
          responseJSON = json.decode(response.body.toString());
        });
      }
    } on Exception {
      responseJSON = {"error": "Network Exception"};
    }
    return responseJSON;
  }
}
