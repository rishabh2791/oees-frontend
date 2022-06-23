import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class DeviceDataWidget extends StatefulWidget {
  const DeviceDataWidget({Key? key}) : super(key: key);

  @override
  State<DeviceDataWidget> createState() => _DeviceDataWidgetState();
}

class _DeviceDataWidgetState extends State<DeviceDataWidget> {
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
