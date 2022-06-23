import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class PlantCreateWidget extends StatefulWidget {
  const PlantCreateWidget({Key? key}) : super(key: key);

  @override
  State<PlantCreateWidget> createState() => _PlantCreateWidgetState();
}

class _PlantCreateWidgetState extends State<PlantCreateWidget> {
  bool isLoading = false;
  late Map<String, dynamic> map;
  late FormFieldWidget formFieldWidget;
  late TextFormFielder codeFormWidget, descriptionFormWidget;
  late TextEditingController codeController, descriptionController;

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
    descriptionController = TextEditingController();
    codeFormWidget = TextFormFielder(
      controller: codeController,
      formField: "code",
      label: "Plant Code",
      minSize: 4,
      maxSize: 4,
    );
    descriptionFormWidget = TextFormFielder(
      controller: descriptionController,
      formField: "description",
      label: "Plant Description",
      obscureText: false,
      minSize: 10,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        codeFormWidget,
        descriptionFormWidget,
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
                        "Create Plant",
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
                                  await appStore.plantApp.create(map).then((response) async {
                                    if (response.containsKey("status") && response["status"]) {
                                      setState(() {
                                        errorMessage = "Plant Created";
                                        isError = true;
                                      });
                                      formFieldWidget.clear();
                                    } else {
                                      setState(() {
                                        errorMessage = "Unable to create Plant.";
                                        isError = true;
                                      });
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
