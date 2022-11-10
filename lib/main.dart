import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/auth/login_widget.dart';
import 'package:oees/interface/home/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  accessTokenExpiryTime = DateTime.now();
  numberFormat = NumberFormat.decimalPattern('en_US');
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
  bool isLoading = true;
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    await Future.forEach([await parseStringToMap()], (element) => null)
        .then((value) {});
  }

  Future<void> parseStringToMap({String assetsFileName = '.env'}) async {
    final lines = await rootBundle.loadString(assetsFileName);
    Map<String, String> environment = {};
    for (String line in lines.split('\n')) {
      line = line.trim();
      if (line.contains('=') //Set Key Value Pairs on lines separated by =
          &&
          !line.startsWith(RegExp(r'=|#'))) {
        //No need to add emty keys and remove comments
        List<String> contents = line.split('=');
        environment[contents[0]] = contents.sublist(1).join('=');
      }
    }
    baseURL = environment["baseURL"] ?? "http://10.19.0.71/backend/";
    webSocketURL = environment["WEBSOCKET_URL"] ?? "ws://10.19.0.71:8001/";
    username = environment["USERNAME"] ?? "";
    password = environment["PASSWORD"] ?? "";
    setState(() {
      isLoading = false;
    });
  }

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
      home: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : isLoggedIn
              ? const HomeWidget()
              : const LoginWidget(),
    );
  }
}
