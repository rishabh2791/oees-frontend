import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class PlantGetWidget extends StatefulWidget {
  const PlantGetWidget({Key? key}) : super(key: key);

  @override
  State<PlantGetWidget> createState() => _PlantGetWidgetState();
}

class _PlantGetWidgetState extends State<PlantGetWidget> {
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
