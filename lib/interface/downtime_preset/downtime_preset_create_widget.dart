import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/downtime_preset.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/int_form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class DowntimePresetCreateWidget extends StatefulWidget {
  const DowntimePresetCreateWidget({Key? key}) : super(key: key);

  @override
  State<DowntimePresetCreateWidget> createState() => _DowntimePresetCreateWidgetState();
}

class _DowntimePresetCreateWidgetState extends State<DowntimePresetCreateWidget> {
  bool isLoading = true;
  bool isDataLoaded = false;
  Map<String, dynamic> map = {};
  late IntFormFielder defaultPeriodFormField;
  late FormFieldWidget plantFormWidget, mainFormWidget;
  late DropdownFormField typeFormField;
  late TextFormFielder descriptionFormField;
  late TextEditingController typeController, periodController, descriptionController;

  @override
  void initState() {
    periodController = TextEditingController();
    typeController = TextEditingController();
    descriptionController = TextEditingController();
    initForm();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initForm() {
    descriptionFormField = TextFormFielder(
      controller: descriptionController,
      formField: "description",
      label: "Downtime Description",
      minSize: 5,
      maxSize: 100,
    );
    typeFormField = DropdownFormField(
      formField: "type",
      controller: typeController,
      dropdownItems: downtimeTypes,
      hint: "Downtime Type",
    );
    defaultPeriodFormField = IntFormFielder(
      controller: periodController,
      formField: "default_period",
      label: "Default Period (min)",
    );
    mainFormWidget = FormFieldWidget(
      formFields: [
        typeFormField,
        descriptionFormField,
        defaultPeriodFormField,
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
                        "Create Preset Downtime",
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
                      mainFormWidget.render(),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              onPressed: () async {
                                if (mainFormWidget.validate()) {
                                  map = mainFormWidget.toJSON();
                                  await appStore.downtimePresetApp.create(map).then((response) {
                                    if (response.containsKey("status") && response["status"]) {
                                      setState(() {
                                        errorMessage = "Preset Created";
                                        isError = true;
                                      });
                                      navigationService.pushReplacement(
                                        CupertinoPageRoute(
                                          builder: (BuildContext context) => const DowntimePresetCreateWidget(),
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
                                          errorMessage = "Unable to Create Download Preset.";
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
                                    builder: (BuildContext context) => const DowntimePresetCreateWidget(),
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
                      )
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
