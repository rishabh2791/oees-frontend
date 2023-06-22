import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/user_role.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown.dart';
import 'package:oees/interface/common/permission_code_selector.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';

class UserRoleAccessCreateWidget extends StatefulWidget {
  const UserRoleAccessCreateWidget({Key? key}) : super(key: key);

  @override
  State<UserRoleAccessCreateWidget> createState() => _UserRoleAccessCreateWidgetState();
}

class _UserRoleAccessCreateWidgetState extends State<UserRoleAccessCreateWidget> {
  List<String> tables = [];
  List<UserRole> userRoles = [];
  bool isLoadingData = false;
  bool isRoleSelected = false;
  late TextEditingController userRoleController;
  Map<String, TextEditingController> controllers = {};
  Map<String, String> existingPermissions = {};

  @override
  void initState() {
    getAllData();
    userRoleController = TextEditingController();
    userRoleController.addListener(listenToRoleChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getAllData() async {
    await Future.forEach([
      await getUserRoles(),
      await getTables(),
    ], (element) {
      setState(() {
        isLoadingData = false;
      });
    });
  }

  Future<void> getUserRoles() async {
    await appStore.userRoleApp.list({}).then((response) async {
      if (response["status"]) {
        for (var item in response["payload"]) {
          if (item["role"] != "Superuser") {
            UserRole userRole = UserRole.fromJSON(item);
            userRoles.add(userRole);
          }
        }
      } else {
        Navigator.of(context).pop();
        setState(() {
          isError = true;
          errorMessage = "Unable to Load User Roles";
        });
      }
    });
    userRoles.sort(((a, b) => a.description.compareTo(b.description)));
  }

  Future<void> getTables() async {
    await appStore.commonApp.getTables().then((response) async {
      if (response.containsKey("error")) {
        Navigator.of(context).pop();
        setState(() {
          isError = true;
          errorMessage = "Unable to Load Tables";
        });
      } else {
        if (response["status"]) {
          for (var item in response["payload"]) {
            if (!item.toString().contains("compan")) {
              tables.add(item);
            }
          }
        } else {
          Navigator.of(context).pop();
          setState(() {
            isError = true;
            errorMessage = "Unable to Load User Roles";
          });
        }
      }
    });
  }

  List<Widget> getItems() {
    List<Widget> items = [];
    if (tables.isNotEmpty) {
      for (var table in tables) {
        controllers[table] = TextEditingController();
        controllers[table]!.text = existingPermissions[table] ?? "0000";
        Widget item = PermissionCodeSelector(
          title: table.toString().replaceAll("_", " ").toUpperCase(),
          codeController: controllers[table]!,
        );
        items.add(item);
      }
    }
    return items;
  }

  void listenToRoleChange() async {
    String userRole = userRoleController.text;
    if (userRole.isEmpty || userRole == "") {
      setState(() {
        isError = true;
        errorMessage = "Unable to Load User Roles";
        isRoleSelected = false;
      });
    } else {
      setState(() {
        isRoleSelected = true;
        isLoadingData = true;
      });
      await Future.forEach([
        await getUserRoleAcces(userRoleController.text),
      ], (element) {
        setState(() {
          isLoadingData = false;
        });
      });
    }
  }

  Future<void> getUserRoleAcces(String userRole) async {
    existingPermissions = {};
    await appStore.userRoleAccessApp.list(userRole).then((response) {
      if (response.containsKey("error")) {
        setState(() {
          isError = true;
          errorMessage = response["error"];
          isRoleSelected = false;
        });
      } else {
        if (response["status"]) {
          for (var item in response["payload"]) {
            existingPermissions[item["tablename"]] = item["access_code"];
          }
        } else {
          setState(() {
            isError = true;
            errorMessage = response["message"];
            isRoleSelected = false;
          });
        }
      }
    });
  }

  Widget createWidget() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create User Role",
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
          SizedBox(
            width: MediaQuery.of(context).size.width * .3,
            child: DropDownWidget(
              disabled: false,
              hint: "Select User Role",
              controller: userRoleController,
              dropdownItems: userRoles,
            ),
          ),
          isRoleSelected
              ? Column(
                  children: getItems(),
                )
              : Container(),
          isRoleSelected
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                  child: Row(
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(isDarkTheme.value ? foregroundColor : backgroundColor),
                          elevation: MaterialStateProperty.all<double>(5.0),
                        ),
                        onPressed: () async {
                          List<Map<String, dynamic>> permissions = [];
                          controllers.forEach((key, value) {
                            permissions.add({
                              "user_role_id": userRoleController.text,
                              "tablename": key,
                              "access_code": value.text,
                            });
                          });
                          setState(() {
                            isLoadingData = true;
                          });
                          await appStore.userRoleAccessApp.createMultiple(permissions).then((response) async {
                            if (response["status"]) {
                              setState(() {
                                isLoadingData = false;
                                errorMessage = "Access Updated";
                                isError = true;
                              });
                            } else {
                              setState(() {
                                isLoadingData = false;
                                errorMessage = response["message"];
                                isError = true;
                              });
                            }
                          });
                        },
                        child: checkButton(),
                      )
                    ],
                  ),
                )
              : Container(),
          const Divider(
            height: 60.0,
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isDarkTheme,
        builder: ((context, value, child) {
          return isLoadingData
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                    color: isDarkTheme.value ? backgroundColor : foregroundColor,
                  ),
                )
              : SuperWidget(
                  childWidget: createWidget(),
                  errorCallback: () {
                    setState(
                      () {
                        isError = false;
                        errorMessage = "";
                      },
                    );
                  },
                );
        }));
  }
}
