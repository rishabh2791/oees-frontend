import 'package:flutter/material.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/auth/login_widget.dart';
import 'package:oees/interface/home/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  accessTokenExpiryTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  Future<SharedPreferences> store = SharedPreferences.getInstance();
  storage = await store;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unza - Management Information System',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
      ),
      navigatorKey: navigationService.navigatorKey,
      home: isLoggedIn ? const HomeWidget() : const LoginWidget(),
    );
  }
}
