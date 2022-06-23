import 'package:flutter/material.dart';
import 'package:oees/domain/entity/device.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class DeviceViewWidget extends StatefulWidget {
  final Device device;
  const DeviceViewWidget({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<DeviceViewWidget> createState() => _DeviceViewWidgetState();
}

class _DeviceViewWidgetState extends State<DeviceViewWidget> {
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
