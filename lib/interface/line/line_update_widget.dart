import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class LineUpdateWidget extends StatefulWidget {
  const LineUpdateWidget({Key? key}) : super(key: key);

  @override
  State<LineUpdateWidget> createState() => _LineUpdateWidgetState();
}

class _LineUpdateWidgetState extends State<LineUpdateWidget> {
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
