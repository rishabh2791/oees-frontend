import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/user.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';
import 'package:oees/interface/home/home_widget.dart';
import 'package:oees/interface/middlewares/refresh_token.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool isLoading = false;
  late Map<String, dynamic> map;
  late FormFieldWidget formFieldWidget;
  late TextFormFielder usernameFormWidget, passwordFormWidget;
  late TextEditingController usernameController, passwordController;

  @override
  void initState() {
    initForm();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initForm() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    usernameFormWidget = TextFormFielder(
      controller: usernameController,
      formField: "username",
      label: "Username",
      minSize: 8,
    );
    passwordFormWidget = TextFormFielder(
      controller: passwordController,
      formField: "password",
      label: "Password",
      obscureText: true,
      minSize: 8,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        usernameFormWidget,
        passwordFormWidget,
      ],
    );
    setState(() {
      isLoading = false;
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
                childWidget: BaseWidget(
                  builder: (context, sizeInfo) {
                    return SizedBox(
                      height: sizeInfo.screenSize.height,
                      width: sizeInfo.screenSize.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          formFieldWidget.render(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: MaterialButton(
                                  onPressed: () async {
                                    if (formFieldWidget.validate()) {
                                      map = formFieldWidget.toJSON();
                                      await appStore.authApp.login(map).then(
                                        (response) async {
                                          errorMessage = "";
                                          if (response.containsKey("status") && response["status"]) {
                                            var payload = response["payload"];
                                            await storage!.setString("username", payload["username"]);
                                            await storage!.setString("access_token", payload["access_token"]);
                                            await storage!.setString('refresh_token', payload["refresh_token"]);
                                            await storage!.setInt("access_validity", payload["at_duration"]);
                                            await storage!.setBool("logged_in", true);
                                            isLoggedIn = true;
                                            await Future.forEach([await refreshAccessToken()], (element) {}).then(
                                              (value) async {
                                                await appStore.userApp.getUser(payload["username"]).then((value) {
                                                  if (value.containsKey("status") && value["status"]) {
                                                    User user = User.fromJSON(value["payload"]);
                                                    currentUser = user;
                                                    navigationService.pushReplacement(
                                                      CupertinoPageRoute(
                                                        builder: (BuildContext context) => const HomeWidget(),
                                                      ),
                                                    );
                                                  } else {
                                                    setState(() {
                                                      errorMessage = "User Profile Not Found.";
                                                      isError = true;
                                                    });
                                                  }
                                                });
                                              },
                                            );
                                          } else {
                                            setState(() {
                                              errorMessage = "Invalid Credentials";
                                              isError = true;
                                            });
                                          }
                                        },
                                      );
                                    } else {
                                      setState(() {
                                        isError = true;
                                      });
                                    }
                                  },
                                  color: foregroundColor,
                                  height: 60.0,
                                  minWidth: 50.0,
                                  child: checkButton(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: MaterialButton(
                                  onPressed: () {
                                    formFieldWidget.clear();
                                  },
                                  color: foregroundColor,
                                  height: 60.0,
                                  minWidth: 50.0,
                                  child: clearButton(),
                                ),
                              ),
                            ],
                          ),
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
      },
    );
  }
}
