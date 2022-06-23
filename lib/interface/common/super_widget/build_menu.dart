import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/auth/login_widget.dart';

List<Widget> buildMenu(
  Map<String, Map<String, dynamic>> menuItems,
  AnimationController animationController,
) {
  List<Widget> menus = [];
  if (!isLoggedIn) {
    return [];
  } else {
    menus.add(
      Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(blurRadius: 10, color: isDarkTheme.value ? backgroundColor : foregroundColor, spreadRadius: 5)],
        ),
        child: CircleAvatar(
          backgroundImage: NetworkImage(baseURL + currentUser.profilePic),
          radius: 75,
        ),
      ),
    );
    menus.add(
      const Divider(
        color: Colors.transparent,
        height: 40.0,
      ),
    );
    menus.add(
      Text(
        currentUser.firstName + " " + currentUser.lastName,
        style: TextStyle(
          fontSize: 24.0,
          color: isDarkTheme.value ? backgroundColor : foregroundColor,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
    menus.add(
      Text(
        "@" + currentUser.username,
        style: TextStyle(
          fontSize: 24.0,
          color: isDarkTheme.value ? backgroundColor : foregroundColor,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
    menus.add(
      const Divider(
        color: Colors.transparent,
        height: 40.0,
      ),
    );
    menuItems.forEach((key, value) {
      menus.add(
        InkWell(
          onTap: () {
            animationController.reverse();
            menuItemSelected = key;
            isMenuCollapsed = true;
            navigationService.pushAndRemoveUntil(
              CupertinoPageRoute(builder: (BuildContext context) => value["widget"]),
            );
          },
          child: Text(
            key.toUpperCase().replaceAll("_", " "),
            style: TextStyle(
              color: menuItemSelected == key
                  ? isDarkTheme.value
                      ? backgroundColor
                      : foregroundColor
                  : isDarkTheme.value
                      ? backgroundColor.withOpacity(0.5)
                      : foregroundColor.withOpacity(0.5),
              fontSize: 20.0,
              fontWeight: menuItemSelected == key ? FontWeight.bold : FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    });
    menus.add(
      const Divider(
        color: Colors.transparent,
        height: 40.0,
      ),
    );
    menus.add(
      TextButton(
        onPressed: () async {
          logout();
        },
        child: Text(
          "Logout",
          style: TextStyle(
            fontSize: 24.0,
            color: isDarkTheme.value ? backgroundColor : foregroundColor,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  menus.add(
    const Divider(
      color: Colors.transparent,
      height: 100.0,
    ),
  );
  return menus;
}

Future<void> logout() async {
  await appStore.authApp
      .logout()
      .then((value) async => await Future.forEach([
            await storage?.remove("username"),
            await storage?.remove("access_token"),
            await storage?.remove("refresh_token"),
            await storage?.remove("access_validity"),
            await storage?.remove("logged_in"),
          ], (element) => null))
      .then(
    (value) {
      isLoggedIn = false;
      isMenuCollapsed = true;
      companyID = "";
      factoryID = "";
    },
  ).then(
    (value) {
      menuItemSelected = "Home";
      navigationService.pushReplacement(
        CupertinoPageRoute(
          builder: (BuildContext context) => const LoginWidget(),
        ),
      );
    },
  );
}
