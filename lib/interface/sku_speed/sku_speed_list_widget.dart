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
import 'package:oees/interface/common/lists/sku_speed_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class SKUSpeedListWidget extends StatefulWidget {
  const SKUSpeedListWidget({Key? key}) : super(key: key);

  @override
  State<SKUSpeedListWidget> createState() => _SKUSpeedListWidgetState();
}

class _SKUSpeedListWidgetState extends State<SKUSpeedListWidget> {
  bool isLoading = true;
  bool isPlantLoaded = false;
  bool isDataLoaded = false;
  List<Line> lines = [];
  List<Plant> plants = [];
  List<SKU> skus = [];
  List<SKUSpeed> skuSpeeds = [];
  Map<String, dynamic> map = {};
  late DropdownFormField plantFormField, lineFormField, skuFormField;
  late TextEditingController plantController, lineController, skuController;
  late FormFieldWidget plantFormFieldWidget, lineFormFieldWidget;

  @override
  void initState() {
    plantController = TextEditingController();
    lineController = TextEditingController();
    skuController = TextEditingController();
    getPlants();
    plantController.addListener(getData);
    super.initState();
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
      isPlantLoaded = true;
    });
    await Future.forEach([await getLines(), await getSKUs()], (element) {
      if (errorMessage.isEmpty && errorMessage == "") {
        initForm();
      }
      setState(() {
        isLoading = false;
      });
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
    lineFormFieldWidget = FormFieldWidget(
      formFields: [
        lineFormField,
        skuFormField,
      ],
    );
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
                        "List SKU Speeds",
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
                      isDataLoaded
                          ? Container()
                          : isPlantLoaded
                              ? lineFormFieldWidget.render()
                              : plantFormFieldWidget.render(),
                      isDataLoaded
                          ? skuSpeeds.isNotEmpty
                              ? SKUSpeedList(skuSpeeds: skuSpeeds)
                              : Text(
                                  "No SKU Speeds Found",
                                  style: TextStyle(
                                    color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                          : isPlantLoaded
                              ? Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          Map<String, dynamic> conditions = {}, lineConditions = {}, skuConditions = {};
                                          map = lineFormFieldWidget.toJSON();
                                          if (lineController.text.isNotEmpty) {
                                            lineConditions = {
                                              "EQUALS": {
                                                "Field": "line_id",
                                                "Value": map["line_id"],
                                              }
                                            };
                                          } else {
                                            List<String> lineIDs = [];
                                            for (var line in lines) {
                                              lineIDs.add(line.id);
                                            }
                                            lineConditions = {
                                              "IN": {
                                                "Field": "line_id",
                                                "Value": lineIDs,
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
                                          } else {
                                            List<String> skuIDs = [];
                                            for (var sku in skus) {
                                              skuIDs.add(sku.id);
                                            }
                                            skuConditions = {
                                              "IN": {
                                                "Field": "sku_id",
                                                "Value": skuIDs,
                                              }
                                            };
                                          }
                                          conditions = {
                                            "AND": [
                                              lineConditions,
                                              skuConditions,
                                            ],
                                          };
                                          skuSpeeds = [];
                                          await appStore.skuSpeedApp.list(conditions).then((response) {
                                            if (response.containsKey("status") && response["status"]) {
                                              for (var item in response["payload"]) {
                                                SKUSpeed skuSpeed = SKUSpeed.fromJSON(item);
                                                skuSpeeds.add(skuSpeed);
                                              }
                                              setState(() {
                                                isDataLoaded = true;
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
                                          });
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
                                              builder: (BuildContext context) => const SKUSpeedListWidget(),
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
