import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/plant.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/int_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class SKUSpeedCreateWidget extends StatefulWidget {
  const SKUSpeedCreateWidget({Key? key}) : super(key: key);

  @override
  State<SKUSpeedCreateWidget> createState() => _SKUSpeedCreateWidgetState();
}

class _SKUSpeedCreateWidgetState extends State<SKUSpeedCreateWidget> {
  bool isLoading = true;
  bool isDataLoaded = false;
  List<Plant> plants = [];
  List<SKU> skus = [];
  List<Line> lines = [];
  late Map<String, dynamic> map;
  late FormFieldWidget plantFormFieldWidget, formFieldWidget;
  late DropdownFormField plantFormField, skuFormField, lineFormField;
  late IntFormFielder speedFormWidget;
  late TextEditingController plantController, lineController, skuController, speedController;

  @override
  void initState() {
    plantController = TextEditingController();
    lineController = TextEditingController();
    speedController = TextEditingController();
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
    speedFormWidget = IntFormFielder(
      controller: speedController,
      formField: "speed",
      label: "Speed in Units/Minute",
      isRequired: true,
      min: 1,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        lineFormField,
        skuFormField,
        speedFormWidget,
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
                        "Create SKU Speed",
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
                                        map["speed"] = double.parse(map["speed"].toString());
                                        map["created_by_username"] = currentUser.username;
                                        map["updated_by_username"] = currentUser.username;
                                        await appStore.skuSpeedApp.create(map).then((response) {
                                          if (response.containsKey("status") && response["status"]) {
                                            setState(() {
                                              errorMessage = "SKU Speed Created";
                                              isError = true;
                                            });
                                            navigationService.pushReplacement(
                                              CupertinoPageRoute(
                                                builder: (BuildContext context) => const SKUSpeedCreateWidget(),
                                              ),
                                            );
                                          } else {
                                            if (!response.containsKey("status")) {
                                              setState(() {
                                                errorMessage = "Unable to Create SKU Speed.";
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
                                          builder: (BuildContext context) => const SKUSpeedCreateWidget(),
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
