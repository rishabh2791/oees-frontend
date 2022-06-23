import 'package:flutter/cupertino.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/auth/login_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> refreshAccessToken() async {
  String token;
  bool loggedIn = false;
  SharedPreferences storage = await SharedPreferences.getInstance();

  token = storage.getString("refresh_token") ?? "";
  loggedIn = storage.getBool("logged_in") ?? false;

  if (token != "" && loggedIn) {
    await storage.setBool("logged_in", false);
    isRefreshing = true;

    await appStore.authApp.refresh().then(
      (response) async {
        if (response.containsKey("status") && response["status"]) {
          var payload = response["payload"];
          await storage.setString("access_token", payload["access_token"]);
          await storage.setString('refresh_token', payload["refresh_token"]);
          await storage.setInt("access_validity", payload["at_duration"]);
          await storage.setBool("logged_in", true);
          isLoggedIn = true;
          isRefreshing = false;
          accessTokenExpiryTime = DateTime.now().add(Duration(seconds: int.parse(payload["at_duration"].toString())));
        } else {
          navigationService.pushReplacement(CupertinoPageRoute(builder: (BuildContext context) => const LoginWidget()));
        }
      },
    );
  }
}
