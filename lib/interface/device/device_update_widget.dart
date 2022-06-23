import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class DeviceUpdateWidget extends StatefulWidget {
  const DeviceUpdateWidget({Key? key}) : super(key: key);

  @override
  State<DeviceUpdateWidget> createState() => _DeviceUpdateWidgetState();
}

class _DeviceUpdateWidgetState extends State<DeviceUpdateWidget> {
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
