import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/user.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/lists/users.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class UserListWidget extends StatefulWidget {
  const UserListWidget({Key? key}) : super(key: key);

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  List<User> users = [];
  bool isLoadingData = true;

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getUsers() async {
    await appStore.userApp.list({}).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          User user = await User.fromJSON(item);
          users.add(user);
        }
      } else {
        setState(() {
          isError = true;
          errorMessage = "No Users found.";
        });
      }
      setState(() {
        isLoadingData = false;
      });
    });
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
                childWidget: Center(
                  child: Column(
                    children: [
                      Text(
                        "All Users",
                        style: TextStyle(
                          color: isDarkTheme.value ? foregroundColor : backgroundColor,
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(
                        height: 50,
                        color: Colors.transparent,
                      ),
                      UserList(users: users),
                    ],
                  ),
                ),
                errorCallback: () {
                  setState(() {
                    isError = true;
                    errorMessage = "";
                  });
                });
      }),
    );
  }
}
