import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/double_form_field.dart';
import 'package:oees/interface/common/form_fields/file_picker.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/int_form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';
import 'package:flutter/foundation.dart' as foundation;

class SKUCreateWidget extends StatefulWidget {
  const SKUCreateWidget({Key? key}) : super(key: key);

  @override
  State<SKUCreateWidget> createState() => _SKUCreateWidgetState();
}

class _SKUCreateWidgetState extends State<SKUCreateWidget> {
  bool isLoading = true;
  late Map<String, dynamic> map;
  late FormFieldWidget formFieldWidget;
  late TextFormFielder codeFormWidget, descriptionFormWidget;
  late IntFormFielder caseLotFormWidget,
      lowRunSpeedFormWidget,
      highRunSpeedFormWidget;
  late DoubleFormFielder minWeightFormWidget,
      maxWeightFormWidget,
      expectedWeightFormWidget;
  late FilePickerResult? file;
  late TextEditingController codeController,
      descriptionController,
      caseLotController,
      minWeightController,
      maxWeightController,
      expectedWeightController,
      lowRunSpeedController,
      highRunSpeedController,
      fileController;

  @override
  void initState() {
    fileController = TextEditingController();
    initForm();
    super.initState();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getFile(FilePickerResult? result) {
    setState(() {
      file = result;
      fileController.text = result!.files.single.name;
    });
  }

  void initForm() {
    codeController = TextEditingController();
    descriptionController = TextEditingController();
    caseLotController = TextEditingController();
    minWeightController = TextEditingController();
    maxWeightController = TextEditingController();
    expectedWeightController = TextEditingController();
    lowRunSpeedController = TextEditingController();
    highRunSpeedController = TextEditingController();
    codeFormWidget = TextFormFielder(
      controller: codeController,
      formField: "code",
      label: "Material Code",
      minSize: 4,
      maxSize: 10,
    );
    descriptionFormWidget = TextFormFielder(
      controller: descriptionController,
      formField: "description",
      label: "Material Description",
      obscureText: false,
      minSize: 10,
    );
    caseLotFormWidget = IntFormFielder(
      controller: caseLotController,
      formField: "case_lot",
      label: "Units/Case",
      isRequired: true,
      min: 1,
    );
    minWeightFormWidget = DoubleFormFielder(
      controller: minWeightController,
      formField: "min_weight",
      label: "Minimum Weight",
      isRequired: true,
      min: 1,
    );
    maxWeightFormWidget = DoubleFormFielder(
      controller: maxWeightController,
      formField: "max_weight",
      label: "Maximum Weight",
      isRequired: true,
      min: 1,
    );
    expectedWeightFormWidget = DoubleFormFielder(
      controller: expectedWeightController,
      formField: "expected_weight",
      label: "Expected Weight",
      isRequired: true,
      min: 1,
    );
    lowRunSpeedFormWidget = IntFormFielder(
      controller: lowRunSpeedController,
      formField: "low_run_speed",
      label: "Low Run Speed",
      isRequired: true,
      min: 1,
    );
    highRunSpeedFormWidget = IntFormFielder(
      controller: highRunSpeedController,
      formField: "high_run_speed",
      label: "High Run Speed",
      isRequired: true,
      min: 1,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        codeFormWidget,
        descriptionFormWidget,
        caseLotFormWidget,
        minWeightFormWidget,
        expectedWeightFormWidget,
        lowRunSpeedFormWidget,
        highRunSpeedFormWidget,
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
                        "Create SKU",
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
                                  await appStore.skuApp
                                      .create(map)
                                      .then((response) {
                                    if (response.containsKey("status") &&
                                        response["status"]) {
                                      setState(() {
                                        errorMessage = "SKU Created";
                                        isError = true;
                                      });
                                      navigationService.pushReplacement(
                                        CupertinoPageRoute(
                                          builder: (BuildContext context) =>
                                              const SKUCreateWidget(),
                                        ),
                                      );
                                    } else {
                                      errorMessage = "Unable to Create SKU";
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
                                    builder: (BuildContext context) =>
                                        const SKUCreateWidget(),
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
                      const Divider(
                        height: 40.0,
                        color: Colors.transparent,
                      ),
                      Text(
                        "Create Multiple SKU",
                        style: TextStyle(
                          color: isDarkTheme.value
                              ? foregroundColor
                              : backgroundColor,
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: FilePickerWidget(
                          fileController: fileController,
                          hint: "Select File",
                          label: "Select File",
                          updateParent: getFile,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              onPressed: () async {
                                List<Map<String, dynamic>> skus = [];
                                if (fileController.text.isEmpty) {
                                  setState(() {
                                    isError = true;
                                    errorMessage = "Select File to Upload";
                                  });
                                } else {
                                  // ignore: prefer_typing_uninitialized_variables
                                  var csvData;
                                  if (foundation.kIsWeb) {
                                    final bytes =
                                        utf8.decode(file!.files.single.bytes!);
                                    csvData = const CsvToListConverter()
                                        .convert(bytes);
                                  } else {
                                    final csvFile =
                                        File(file!.files.single.path.toString())
                                            .openRead();
                                    csvData = await csvFile
                                        .transform(utf8.decoder)
                                        .transform(
                                          const CsvToListConverter(),
                                        )
                                        .toList();
                                  }
                                  setState(() {
                                    isLoading = true;
                                  });
                                  csvData.forEach((line) async {
                                    Map<String, dynamic> sku = {
                                      "code": line[0].toString(),
                                      "description": line[1],
                                      "min_weight":
                                          double.parse(line[2].toString()),
                                      "max_weight":
                                          double.parse(line[3].toString()),
                                      "expected_weight":
                                          double.parse(line[4].toString()),
                                      "low_run_speed":
                                          int.parse(line[5].toString()),
                                      "high_run_speed":
                                          int.parse(line[6].toString()),
                                      "created_by_username":
                                          currentUser.username,
                                      "updated_by_username":
                                          currentUser.username,
                                    };
                                    skus.add(sku);
                                  });
                                  await appStore.skuApp
                                      .createMultiple(skus)
                                      .then((response) {
                                    if (response.containsKey("status") &&
                                        response["status"]) {
                                      setState(() {
                                        isError = true;
                                        errorMessage = "SKUs created: " +
                                            response["payload"]["models"]
                                                .length
                                                .toString() +
                                            ". Found Errors in: " +
                                            response["payload"]["errors"]
                                                .length
                                                .toString();
                                      });
                                    } else {
                                      if (response.containsKey("status")) {
                                        setState(() {
                                          errorMessage = response["message"];
                                          isError = true;
                                        });
                                      } else {
                                        setState(() {
                                          errorMessage =
                                              "Unbale to Create SKUs.";
                                          isError = true;
                                        });
                                      }
                                    }
                                  });
                                  setState(() {
                                    isLoading = false;
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
                                        const SKUCreateWidget(),
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
