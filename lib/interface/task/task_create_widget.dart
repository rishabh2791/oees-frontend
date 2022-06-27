import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/job.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/sku_speed.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
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
  List<Line> lines = [];
  late Map<String, dynamic> map;
  late FormFieldWidget formFieldWidget;
  late DropdownFormField skuFormField, lineFormField;
  late TextFormFielder taskFormWidget;
  late TextEditingController lineController, codeController;

  @override
  void initState() {
    getData();
    lineController = TextEditingController();
    codeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initForm() {
    lineFormField = DropdownFormField(
      formField: "line_id",
      controller: lineController,
      dropdownItems: lines,
      hint: "Select Line",
    );
    taskFormWidget = TextFormFielder(
      controller: codeController,
      formField: "code",
      label: "Job Code",
      isRequired: true,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        taskFormWidget,
        lineFormField,
      ],
    );
  }

  Future<void> getLines() async {
    await appStore.lineApp.list({}).then((response) {
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

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    await Future.forEach([await getLines()], (element) {
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
                                  //Get Job Details
                                  Map<String, dynamic> jobConditions = {
                                    "EQUALS": {
                                      "Field": "code",
                                      "Value": map["code"],
                                    }
                                  };
                                  await appStore.jobApp.list(jobConditions).then((response) async {
                                    if (response.containsKey("status") && response["status"]) {
                                      if (response["payload"].isNotEmpty) {
                                        Job job = Job.fromJSON(response["payload"][0]);
                                        // verify SKU Speed Exists
                                        Map<String, dynamic> conditions = {};
                                        map["job_id"] = job.id;
                                        map["plan"] = job.plan;

                                        conditions = {
                                          "AND": [
                                            {
                                              "EQUALS": {
                                                "Field": "line_id",
                                                "Value": map["line_id"],
                                              },
                                            },
                                            {
                                              "EQUALS": {
                                                "Field": "sku_id",
                                                "Value": job.sku.id,
                                              }
                                            }
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
                                                formFieldWidget.clear();
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
                                          errorMessage = "Unable to Start Task";
                                          isError = true;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        errorMessage = "Unable to Start Task";
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
