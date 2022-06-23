import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/device.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/plant.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/lists/device_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class DeviceListWidget extends StatefulWidget {
  const DeviceListWidget({Key? key}) : super(key: key);

  @override
  State<DeviceListWidget> createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  bool isLoading = true;
  bool isPlantLoaded = false;
  bool isDevicesLoaded = false;
  List<Line> lines = [];
  List<Plant> plants = [];
  List<Device> devices = [];
  Map<String, dynamic> map = {};
  late DropdownFormField plantFormField, lineFormField;
  late TextEditingController plantController, lineController;
  late FormFieldWidget plantFormFieldWidget, lineFormFieldWidget;

  @override
  void initState() {
    plantController = TextEditingController();
    lineController = TextEditingController();
    getPlants();
    plantController.addListener(getLines);
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

  void initForm() {
    lineFormField = DropdownFormField(
      formField: "line_id",
      controller: lineController,
      dropdownItems: lines,
      hint: "Select Line",
    );

    lineFormFieldWidget = FormFieldWidget(
      formFields: [
        lineFormField,
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
                        "List Devices",
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
                      isDevicesLoaded
                          ? Container()
                          : isPlantLoaded
                              ? lineFormFieldWidget.render()
                              : plantFormFieldWidget.render(),
                      isDevicesLoaded
                          ? devices.isNotEmpty
                              ? DeviceList(devices: devices)
                              : Text(
                                  "No Devices Found",
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
                                          Map<String, dynamic> conditions = {};
                                          if (lineController.text.isNotEmpty) {
                                            map = lineFormFieldWidget.toJSON();
                                            conditions = {
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
                                            conditions = {
                                              "IN": {
                                                "Field": "line_id",
                                                "Value": lineIDs,
                                              }
                                            };
                                          }
                                          devices = [];
                                          await appStore.deviceApp.list(conditions).then((response) {
                                            if (response.containsKey("status") && response["status"]) {
                                              for (var item in response["payload"]) {
                                                Device device = Device.fromJSON(item);
                                                devices.add(device);
                                              }
                                              setState(() {
                                                isDevicesLoaded = true;
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
                                              builder: (BuildContext context) => const DeviceListWidget(),
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
