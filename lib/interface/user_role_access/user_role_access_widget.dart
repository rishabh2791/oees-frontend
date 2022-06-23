import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class UserRoleAccessWidget extends StatefulWidget {
  const UserRoleAccessWidget({Key? key}) : super(key: key);

  @override
  State<UserRoleAccessWidget> createState() => _UserRoleAccessWidgetState();
}

class _UserRoleAccessWidgetState extends State<UserRoleAccessWidget> {
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
