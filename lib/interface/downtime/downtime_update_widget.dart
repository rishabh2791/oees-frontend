import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class DowntimeUpdateWidget extends StatefulWidget {
  const DowntimeUpdateWidget({Key? key}) : super(key: key);

  @override
  State<DowntimeUpdateWidget> createState() => _DowntimeUpdateWidgetState();
}

class _DowntimeUpdateWidgetState extends State<DowntimeUpdateWidget> {
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
