import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class PlantUpdateWidget extends StatefulWidget {
  const PlantUpdateWidget({Key? key}) : super(key: key);

  @override
  State<PlantUpdateWidget> createState() => _PlantUpdateWidgetState();
}

class _PlantUpdateWidgetState extends State<PlantUpdateWidget> {
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
