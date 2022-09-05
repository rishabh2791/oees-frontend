import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';

class UserActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String table;
  final String accessType;
  final VoidCallback callback;

  const UserActionButton({
    Key? key,
    required this.accessType,
    required this.callback,
    required this.icon,
    required this.label,
    required this.table,
  }) : super(key: key);

  @override
  State<UserActionButton> createState() => _UserActionButtonState();
}

String getAccessCode(String tableName, String accessType) {
  String accessCode = "0000";
  for (var userPermission in userRolePermissions) {
    if (userPermission.table == tableName) {
      accessCode = userPermission.accessCode;
    }
  }
  switch (accessType) {
    case "create":
      return accessCode[0];
    case "view":
      return accessCode[1];
    case "update":
      return accessCode[2];
    case "delete":
      return accessCode[3];
    default:
      break;
  }
  return "0";
}

class _UserActionButtonState extends State<UserActionButton> {
  Map<String, String> actionMapping = {
    "create": "create",
    "details": "view",
    "list": "view",
    "update": "update",
    "activate": "update",
    "deactivate": "update",
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkTheme,
      builder: (context, darkTheme, child) {
        return SizedBox(
          height: 150,
          width: 200,
          child: Tooltip(
            message: widget.label,
            child: InkWell(
              onTap: () {
                if (getAccessCode(widget.table, widget.accessType) == "1" || (currentUser.userRole.description == "Superuser")) {
                  widget.callback();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 500),
                      backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                      content: Center(
                        child: Text(
                          "You are not Authorized.",
                          style: TextStyle(
                            fontSize: 30.0,
                            color: isDarkTheme.value ? backgroundColor : foregroundColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkTheme.value ? foregroundColor : backgroundColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        spreadRadius: 1.0,
                        blurRadius: 10.0,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        widget.icon,
                        color: isDarkTheme.value ? backgroundColor : foregroundColor,
                        size: 75.0,
                      ),
                      const VerticalDivider(
                        color: Colors.transparent,
                      ),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: isDarkTheme.value ? backgroundColor : foregroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
