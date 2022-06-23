import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/user_role/user_role_create_widget.dart';
import 'package:oees/interface/user_role/user_role_list_widget.dart';

class UserRoleWidget extends StatefulWidget {
  const UserRoleWidget({Key? key}) : super(key: key);

  @override
  State<UserRoleWidget> createState() => _UserRoleWidgetState();
}

class _UserRoleWidgetState extends State<UserRoleWidget> {
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
                            builder: (BuildContext context) => const UserRoleCreateWidget(),
                          ),
                        );
                      },
                      icon: Icons.create,
                      label: "Create Role",
                      table: "user_roles",
                    ),
                    UserActionButton(
                      accessType: "view",
                      callback: () {
                        navigationService.pushReplacement(
                          CupertinoPageRoute(
                            builder: (BuildContext context) => const UserRoleListWidget(),
                          ),
                        );
                      },
                      icon: Icons.list_alt,
                      label: "List Roles",
                      table: "user_roles",
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
