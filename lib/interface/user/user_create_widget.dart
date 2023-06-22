import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/user_role.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/file_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';
import 'package:flutter/foundation.dart' as foundation;

class UserCreateWidget extends StatefulWidget {
  const UserCreateWidget({Key? key}) : super(key: key);

  @override
  State<UserCreateWidget> createState() => _UserCreateWidgetState();
}

class _UserCreateWidgetState extends State<UserCreateWidget> {
  List<UserRole> userRoles = [];
  bool isLoadingData = true;
  late FilePickerResult? file;
  late Map<String, dynamic> map;
  late TextEditingController usernameController,
      passwordController,
      firstNameController,
      lastNameController,
      emailController,
      userRoleController,
      profilePicController;
  late DropdownFormField userRoleFormField;
  late TextFormFielder usernameFormField,
      firstNameFormField,
      lastNameFormField,
      emailFormField,
      passwordFormField;
  late FileFormField profilePicFormField;
  late FormFieldWidget formFieldWidget;

  @override
  void initState() {
    super.initState();
    getUserRole();
    usernameController = TextEditingController();
    userRoleController = TextEditingController();
    passwordController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    profilePicController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getFile(FilePickerResult? result) {
    setState(() {
      file = result;
      profilePicController.text = result!.files.single.name;
    });
  }

  Future<dynamic> getUserRole() async {
    userRoles = [];

    await appStore.userRoleApp.list({}).then((response) async {
      if (response["status"]) {
        for (var item in response["payload"]) {
          if (item["description"] != "Superuser") {
            UserRole userRole = UserRole.fromJSON(item);
            userRoles.add(userRole);
          }
        }
        initForm();
        setState(() {
          isLoadingData = false;
        });
      } else {
        setState(() {
          isLoadingData = false;
          isError = true;
          errorMessage = "Unable to get User Roles";
        });
      }
    });
  }

  void initForm() {
    usernameFormField = TextFormFielder(
      controller: usernameController,
      formField: "username",
      label: "Username",
      minSize: 8,
    );
    passwordFormField = TextFormFielder(
      controller: passwordController,
      formField: "password",
      label: "Password",
      obscureText: true,
    );
    firstNameFormField = TextFormFielder(
      controller: firstNameController,
      formField: "first_name",
      label: "First Name",
    );
    lastNameFormField = TextFormFielder(
      controller: lastNameController,
      formField: "last_name",
      label: "Last Name",
      isRequired: false,
    );
    emailFormField = TextFormFielder(
      controller: emailController,
      formField: "email",
      label: "Email",
      isRequired: false,
    );
    userRoleFormField = DropdownFormField(
      formField: "user_role_id",
      controller: userRoleController,
      dropdownItems: userRoles,
      hint: "Select User Role",
    );
    profilePicFormField = FileFormField(
      fileController: profilePicController,
      formField: "profile_pic",
      hint: "Profile Pic",
      label: "Profile Pic",
      updateParent: getFile,
      allowedExtensions: ['jpg', 'png'],
      isRequired: false,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        usernameFormField,
        passwordFormField,
        userRoleFormField,
        firstNameFormField,
        lastNameFormField,
        emailFormField,
        profilePicFormField,
      ],
    );
  }

  Future<void> handleCreation(Map<String, dynamic> user) async {
    await appStore.userApp.create(user).then(
      (response) async {
        if (response.containsKey("status") && response["status"]) {
          setState(() {
            isError = true;
            errorMessage = "User Created";
          });
        } else {
          setState(() {
            isError = true;
            errorMessage = "User Not Created";
          });
        }
      },
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
                  backgroundColor:
                      isDarkTheme.value ? foregroundColor : backgroundColor,
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                ),
              )
            : SuperWidget(
                childWidget: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create User",
                        style: TextStyle(
                          color: isDarkTheme.value
                              ? foregroundColor
                              : backgroundColor,
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
                                  map = formFieldWidget.toJSON();
                                  map["created_by_username"] =
                                      currentUser.username;
                                  map["updated_by_username"] =
                                      currentUser.username;
                                  if (map.containsKey("profile_pic")) {
                                    var url = baseURL + "image/upload/";
                                    String? token =
                                        storage?.getString("access_token");
                                    Map<String, String> headers = {
                                      "Authorization":
                                          "accessToken " + token.toString(),
                                      "Content-Type": "multipart/form-data",
                                    };
                                    // ignore: prefer_typing_uninitialized_variables
                                    var pic;
                                    var request = http.MultipartRequest(
                                        "POST", Uri.parse(url));
                                    if (foundation.kIsWeb) {
                                      var _bytesData = List<int>.from(
                                          file!.files.single.bytes!);
                                      pic = http.MultipartFile.fromBytes(
                                        "file",
                                        _bytesData,
                                        filename: file!.files.single.name,
                                      );
                                    } else {
                                      pic = await http.MultipartFile.fromPath(
                                          "file",
                                          file!.files.single.path.toString());
                                    }
                                    request.headers.addAll(headers);
                                    request.files.add(pic);
                                    var response = await request.send();
                                    await response.stream
                                        .toBytes()
                                        .then((responseData) {
                                      var responseString =
                                          String.fromCharCodes(responseData);
                                      var responseJSON =
                                          json.decode(responseString);
                                      map["profile_pic"] =
                                          responseJSON["payload"];
                                      handleCreation(map);
                                    });
                                  } else {
                                    map.remove("profile_pic");
                                    handleCreation(map);
                                  }
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
                                    builder: (BuildContext context) =>
                                        const UserCreateWidget(),
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
                  setState(() {
                    isError = false;
                    errorMessage = "";
                  });
                },
              );
      }),
    );
  }
}
