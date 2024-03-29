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

class ShiftCreateWidget extends StatefulWidget {
  const ShiftCreateWidget({Key? key}) : super(key: key);

  @override
  State<ShiftCreateWidget> createState() => _ShiftCreateWidgetState();
}

class _ShiftCreateWidgetState extends State<ShiftCreateWidget> {
  bool isLoading = true;
  late Map<String, dynamic> map;
  late FormFieldWidget formFieldWidget;
  late TextFormFielder codeFormWidget, descriptionFormWidget, startTimeFormWidget, endTimeFormWidget;
  late TextEditingController codeController, nameController, startTimeController, endTimeController;

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
    codeController = TextEditingController();
    nameController = TextEditingController();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
    codeFormWidget = TextFormFielder(
      controller: codeController,
      formField: "code",
      label: "Shift Code",
      maxSize: 4,
    );
    descriptionFormWidget = TextFormFielder(
      controller: nameController,
      formField: "description",
      label: "Shift Description",
      obscureText: false,
      isRequired: true,
      minSize: 5,
    );
    startTimeFormWidget = TextFormFielder(
      controller: startTimeController,
      formField: "start_time",
      label: "Shift Start Time(HH:MM)",
      obscureText: false,
      isRequired: true,
      minSize: 5,
    );
    endTimeFormWidget = TextFormFielder(
      controller: endTimeController,
      formField: "end_time",
      label: "Shift End Time(HH:MM)",
      obscureText: false,
      isRequired: true,
      minSize: 5,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        codeFormWidget,
        descriptionFormWidget,
        startTimeFormWidget,
        endTimeFormWidget,
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
                        "Create Line",
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
                                  map = formFieldWidget.toJSON();
                                  map["created_by_username"] = currentUser.username;
                                  map["updated_by_username"] = currentUser.username;
                                  await appStore.shiftApp.create(map).then((response) {
                                    if (response.containsKey("status") && response["status"]) {
                                      setState(() {
                                        errorMessage = "Shift Created";
                                        isError = true;
                                      });
                                      navigationService.pushReplacement(
                                        CupertinoPageRoute(
                                          builder: (BuildContext context) => const ShiftCreateWidget(),
                                        ),
                                      );
                                    } else {
                                      errorMessage = "Unable to Create Line";
                                      isError = true;
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
                                    builder: (BuildContext context) => const ShiftCreateWidget(),
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
