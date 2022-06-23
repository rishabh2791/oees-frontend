import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class UserRoleCreateWidget extends StatefulWidget {
  const UserRoleCreateWidget({Key? key}) : super(key: key);

  @override
  State<UserRoleCreateWidget> createState() => _UserRoleCreateWidgetState();
}

class _UserRoleCreateWidgetState extends State<UserRoleCreateWidget> {
  bool isLoading = true;
  Map<String, dynamic> map = {};
  late TextEditingController descriptionController;
  late FormFieldWidget formFieldWidget;
  late TextFormFielder descriptionFormField;

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
    descriptionController = TextEditingController();
    descriptionFormField = TextFormFielder(
      controller: descriptionController,
      formField: "description",
      label: "User Role Description",
      obscureText: false,
      isRequired: true,
      minSize: 4,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        descriptionFormField,
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
                childWidget: Center(
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
                      formFieldWidget.render(),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              onPressed: () async {
                                if (formFieldWidget.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  map = formFieldWidget.toJSON();
                                  await appStore.userRoleApp.create(map).then((response) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (response.containsKey("status") && response["status"]) {
                                      setState(() {
                                        errorMessage = "User Role Created";
                                        isError = true;
                                      });
                                      navigationService.pushReplacement(
                                        CupertinoPageRoute(
                                          builder: (BuildContext context) => const UserRoleCreateWidget(),
                                        ),
                                      );
                                    } else {
                                      if (response.containsKey("status")) {
                                        setState(() {
                                          errorMessage = response["message"];
                                          isError = true;
                                        });
                                      } else {
                                        setState(() {
                                          errorMessage = "Unable to create User Role";
                                          isError = true;
                                        });
                                      }
                                    }
                                  });
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
                                navigationService.pushReplacement(
                                  CupertinoPageRoute(
                                    builder: (BuildContext context) => const UserRoleCreateWidget(),
                                  ),
                                );
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
