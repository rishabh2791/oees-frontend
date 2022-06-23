import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/home/general_home_widget.dart';
import 'package:oees/interface/home/oee_home_widget.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool isLoading = true;
  bool isLine = false;
  @override
  void initState() {
    checkDevice();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> checkDevice() async {
    String lineID = storage!.getString("line_id") ?? "";
    if (lineID.isNotEmpty) {
      setState(() {
        isLine = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkTheme,
      builder: (context, darkTheme, child) {
        return isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                ),
              )
            : isLine
                ? SuperWidget(childWidget: const OEEHomeWidget(), errorCallback: () {})
                : SuperWidget(childWidget: const GeneralHomeWidget(), errorCallback: () {});
      },
    );
  }
}
