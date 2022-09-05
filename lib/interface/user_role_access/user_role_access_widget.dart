import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/user_role_access/user_role_access_create_widget.dart';
import 'package:oees/interface/user_role_access/user_role_access_list_widget.dart';

class UserRoleAccessWidget extends StatefulWidget {
  const UserRoleAccessWidget({Key? key}) : super(key: key);

  @override
  State<UserRoleAccessWidget> createState() => _UserRoleAccessWidgetState();
}

class _UserRoleAccessWidgetState extends State<UserRoleAccessWidget> {
  @override
  Widget build(BuildContext context) {
    return SuperWidget(
      childWidget: BaseWidget(
        builder: (context, screenSizeInfo) {
          return SizedBox(
            height: screenSizeInfo.screenSize.height,
            width: screenSizeInfo.screenSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserActionButton(
                      accessType: "create",
                      callback: () {
                        navigationService.pushReplacement(
                          CupertinoPageRoute(
                            builder: (BuildContext context) => const UserRoleAccessCreateWidget(),
                          ),
                        );
                      },
                      icon: Icons.create,
                      label: "Create Access",
                      table: "user_role_accesses",
                    ),
                    UserActionButton(
                      accessType: "view",
                      callback: () {
                        navigationService.pushReplacement(
                          CupertinoPageRoute(
                            builder: (BuildContext context) => const UserRoleAccessListWidget(),
                          ),
                        );
                      },
                      icon: Icons.list_alt,
                      label: "List Access",
                      table: "user_role_accesses",
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
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
