import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class DowntimeListWidget extends StatefulWidget {
  const DowntimeListWidget({Key? key}) : super(key: key);

  @override
  State<DowntimeListWidget> createState() => _DowntimeListWidgetState();
}

class _DowntimeListWidgetState extends State<DowntimeListWidget> {
  @override
  Widget build(BuildContext context) {
    return SuperWidget(
      childWidget: const Center(),
      errorCallback: () {
        setState(
          () {
            isError = false;
            errorMessage = "";
          },
        );
      },
    );
  }
}
