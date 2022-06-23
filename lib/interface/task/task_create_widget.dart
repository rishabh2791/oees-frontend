import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/plant.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/domain/entity/sku_speed.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/int_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class TaskCreateWidget extends StatefulWidget {
  const TaskCreateWidget({Key? key}) : super(key: key);

  @override
  State<TaskCreateWidget> createState() => _TaskCreateWidgetState();
}

class _TaskCreateWidgetState extends State<TaskCreateWidget> {
  bool isLoading = true;
  bool isDataLoaded = false;
  List<Plant> plants = [];
  List<SKU> skus = [];
  List<Line> lines = [];
  late Map<String, dynamic> map;
  late FormFieldWidget plantFormFieldWidget, formFieldWidget;
  late DropdownFormField plantFormField, skuFormField, lineFormField;
  late IntFormFielder taskFormWidget;
  late TextEditingController plantController, lineController, skuController, codeController;

  @override
  void initState() {
    plantController = TextEditingController();
    lineController = TextEditingController();
    codeController = TextEditingController();
    skuController = TextEditingController();
    getPlants();
    super.initState();
    plantController.addListener(getData);
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
    lineFormField = DropdownFormField(
      formField: "line_id",
      controller: lineController,
      dropdownItems: lines,
      hint: "Select Line",
    );
    skuFormField = DropdownFormField(
      formField: "sku_id",
      controller: skuController,
      dropdownItems: skus,
      hint: "Select SKU",
    );
    taskFormWidget = IntFormFielder(
      controller: codeController,
      formField: "code",
      label: "Job Code",
      isRequired: true,
      min: 1,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        taskFormWidget,
        lineFormField,
        skuFormField,
      ],
    );
  }

  Future<void> getLines() async {
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
      } else {
        setState(() {
          errorMessage = "Unable to get Lines.";
          isError = true;
        });
      }
    });
  }

  Future<void> getSKUs() async {
    Map<String, dynamic> conditions = {
      "EQUALS": {
        "Field": "plant_code",
        "Value": plantController.text,
      }
    };
    await appStore.skuApp.list(conditions).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          SKU sku = SKU.fromJSON(item);
          skus.add(sku);
        }
      } else {
        setState(() {
          errorMessage = "Unable to get SKUs.";
          isError = true;
        });
      }
    });
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    await Future.forEach([await getLines(), await getSKUs()], (element) {
      if (errorMessage.isEmpty && errorMessage == "") {
        initForm();
        setState(() {
          isDataLoaded = true;
        });
      }
      setState(() {
        isLoading = false;
      });
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
                        "Create Task",
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
                      isDataLoaded ? formFieldWidget.render() : plantFormFieldWidget.render(),
                      isDataLoaded
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
                                        // verify SKU Speed Exists
                                        Map<String, dynamic> conditions = {}, lineConditions = {}, skuConditions = {};
                                        if (lineController.text.isNotEmpty) {
                                          lineConditions = {
                                            "EQUALS": {
                                              "Field": "line_id",
                                              "Value": map["line_id"],
                                            }
                                          };
                                        }
                                        if (skuController.text.isNotEmpty) {
                                          skuConditions = {
                                            "EQUALS": {
                                              "Field": "sku_id",
                                              "Value": map["sku_id"],
                                            }
                                          };
                                        }
                                        conditions = {
                                          "AND": [
                                            lineConditions,
                                            skuConditions,
                                          ],
                                        };
                                        setState(() {
                                          isLoading = true;
                                        });
                                        List<SKUSpeed> skuSpeeds = [];
                                        await appStore.skuSpeedApp.list(conditions).then((response) async {
                                          if (response.containsKey("status") && response["status"]) {
                                            for (var item in response["payload"]) {
                                              SKUSpeed skuSpeed = SKUSpeed.fromJSON(item);
                                              skuSpeeds.add(skuSpeed);
                                            }
                                            setState(() {
                                              isLoading = false;
                                            });
                                          } else {
                                            if (response.containsKey("status")) {
                                              setState(() {
                                                errorMessage = response["message"];
                                                isError = true;
                                              });
                                            } else {
                                              setState(() {
                                                errorMessage = "Unable to get Devices";
                                                isError = true;
                                              });
                                            }
                                          }
                                          if (skuSpeeds.isEmpty) {
                                            setState(() {
                                              errorMessage = "SKU Speed Not Defined for Line.";
                                              isError = true;
                                            });
                                          } else {
                                            DateTime startTime = DateTime.now();
                                            map["start_time"] = startTime.toUtc().toIso8601String().toString().split(".")[0] + "Z";
                                            await appStore.taskApp.create(map).then((value) {
                                              if (value.containsKey("status") && value["status"]) {
                                                setState(() {
                                                  errorMessage = "Task Created";
                                                  isError = true;
                                                });
                                                navigationService.pushReplacement(
                                                  CupertinoPageRoute(
                                                    builder: (BuildContext context) => const TaskCreateWidget(),
                                                  ),
                                                );
                                              } else {
                                                if (value.containsKey("status")) {
                                                  setState(() {
                                                    errorMessage = value["message"];
                                                    isError = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    errorMessage = "Unable to Create Task";
                                                    isError = true;
                                                  });
                                                }
                                              }
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
                                      navigationService.pushReplacement(
                                        CupertinoPageRoute(
                                          builder: (BuildContext context) => const TaskCreateWidget(),
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
