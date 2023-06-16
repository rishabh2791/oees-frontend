import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/user_role.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/lists/user_role_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class UserRoleListWidget extends StatefulWidget {
  const UserRoleListWidget({Key? key}) : super(key: key);

  @override
  State<UserRoleListWidget> createState() => _UserRoleListWidgetState();
}

class _UserRoleListWidgetState extends State<UserRoleListWidget> {
  bool isLoading = true;
  List<UserRole> userRoles = [];

  @override
  void initState() {
    getUserRoles();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getUserRoles() async {
    userRoles = [];
    await appStore.userRoleApp.list({}).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          UserRole userRole = await UserRole.fromJSON(item);
          userRoles.add(userRole);
        }
      } else {
        setState(() {
          errorMessage = response["message"];
          isError = true;
        });
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkTheme,
      builder: (context, darkTheme, child) {
        return isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                ),
              )
            : SuperWidget(
                childWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "List User Roles",
                      style: TextStyle(
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 50.0,
                    ),
                    userRoles.isNotEmpty
                        ? UserRoleList(userRoles: userRoles)
                        : Text(
                            "No User Roles Found",
                            style: TextStyle(
                              color: isDarkTheme.value ? foregroundColor : backgroundColor,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
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
      },
    );
  }
}
