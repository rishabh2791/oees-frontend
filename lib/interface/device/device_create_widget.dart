import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/plant.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/bool_form_field.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class DeviceCreateWidget extends StatefulWidget {
  const DeviceCreateWidget({Key? key}) : super(key: key);

  @override
  State<DeviceCreateWidget> createState() => _DeviceCreateWidgetState();
}

class _DeviceCreateWidgetState extends State<DeviceCreateWidget> {
  bool isLoading = true, isPlantLoaded = false;
  List<Plant> plants = [];
  List<Line> lines = [];
  late Map<String, dynamic> map;
  late BoolFormField useForOEEFormField;
  late FormFieldWidget plantFormFieldWidget, formFieldWidget;
  late DropdownFormField plantFormField, lineFormField;
  late TextFormFielder codeFormWidget, nameFormWidget, deviceTypeFormWidget;
  late TextEditingController codeController, descriptionController, plantController, lineController, deviceTypeController, userForOEEController;

  @override
  void initState() {
    plantController = TextEditingController();
    codeController = TextEditingController();
    descriptionController = TextEditingController();
    lineController = TextEditingController();
    deviceTypeController = TextEditingController();
    userForOEEController = TextEditingController();
    getPlants();
    super.initState();
    plantController.addListener(getLines);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getPlants() async {
    plants = [];
    await appStore.plantApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Plant plant = Plant.fromJSON(item);
          plants.add(plant);
        }
      } else {
        setState(() {
          errorMessage = response["message"];
          isError = true;
        });
      }
    }).then((value) {
      initPlantForm();
    });
  }

  void initPlantForm() {
    plantFormField = DropdownFormField(
      formField: "plant_code",
      controller: plantController,
      dropdownItems: plants,
      hint: "Select Plant",
      primaryKey: "code",
    );
    plantFormFieldWidget = FormFieldWidget(
      formFields: [
        plantFormField,
      ],
    );
    setState(() {
      isLoading = false;
    });
  }

  void initForm() {
    codeFormWidget = TextFormFielder(
      controller: codeController,
      formField: "code",
      label: "Device Code",
      minSize: 4,
      maxSize: 10,
    );
    lineFormField = DropdownFormField(
      formField: "line_id",
      controller: lineController,
      dropdownItems: lines,
      hint: "Select Line",
    );
    useForOEEFormField = BoolFormField(
      label: "Use For OEE",
      formField: "use_for_oee",
      selectedController: userForOEEController,
    );
    nameFormWidget = TextFormFielder(
      controller: descriptionController,
      formField: "description",
      label: "Device Description",
      obscureText: false,
      minSize: 10,
    );
    deviceTypeFormWidget = TextFormFielder(
      controller: deviceTypeController,
      formField: "device_type",
      label: "Device Type",
      obscureText: false,
      minSize: 4,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        lineFormField,
        codeFormWidget,
        nameFormWidget,
        deviceTypeFormWidget,
        useForOEEFormField,
      ],
    );
  }

  Future<void> getLines() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> conditions = {
      "EQUALS": {
        "Field": "plant_code",
        "Value": plantController.text,
      }
    };
    await appStore.lineApp.list(conditions).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Line line = Line.fromJSON(item);
          lines.add(line);
        }
        initForm();
        setState(() {
          isLoading = false;
          isPlantLoaded = true;
        });
      } else {
        setState(() {
          errorMessage = "Unable to get Lines.";
          isError = true;
        });
      }
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
                        "Create Device",
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
                      isPlantLoaded ? formFieldWidget.render() : plantFormFieldWidget.render(),
                      isPlantLoaded
                          ? Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: MaterialButton(
                                    onPressed: () async {
                                      if (formFieldWidget.validate()) {
                                        map = formFieldWidget.toJSON();
                                        map["created_by_username"] = currentUser.username;
                                        map["updated_by_username"] = currentUser.username;
                                        map["use_for_oee"] = map["use_for_oee"] == "1" ? true : false;
                                        await appStore.deviceApp.create(map).then((response) {
                                          if (response.containsKey("status") && response["status"]) {
                                            setState(() {
                                              errorMessage = "Device Created";
                                              isError = true;
                                            });
                                            navigationService.pushReplacement(
                                              CupertinoPageRoute(
                                                builder: (BuildContext context) => const DeviceCreateWidget(),
                                              ),
                                            );
                                          } else {
                                            if (!response.containsKey("status")) {
                                              setState(() {
                                                errorMessage = "Unable to Create Device";
                                                isError = true;
                                              });
                                            } else {
                                              setState(() {
                                                errorMessage = response["message"];
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
                                          builder: (BuildContext context) => const DeviceCreateWidget(),
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
                          : Container(),
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
