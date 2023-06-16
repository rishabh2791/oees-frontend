import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/job.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/lists/downtime.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class DowntimeListWidget extends StatefulWidget {
  const DowntimeListWidget({Key? key}) : super(key: key);

  @override
  State<DowntimeListWidget> createState() => _DowntimeListWidgetState();
}

class _DowntimeListWidgetState extends State<DowntimeListWidget> {
  bool isLoading = true;
  bool isDataLoaded = false;
  List<Downtime> taskDowntimes = [];
  late TextEditingController jobCodeController;
  late TextFormFielder jobCodeFormField;
  late FormFieldWidget formFieldWidget;

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
    jobCodeController = TextEditingController();
    jobCodeFormField = TextFormFielder(
      controller: jobCodeController,
      formField: "job_code",
      label: "Job Code",
    );
    formFieldWidget = FormFieldWidget(
      formFields: [jobCodeFormField],
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
            : isDataLoaded
                ? SuperWidget(
                    childWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Task Downtimes",
                          style: TextStyle(
                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        taskDowntimes.isEmpty
                            ? Text(
                                "No Task Downtimes",
                                style: TextStyle(
                                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : DowntimeList(
                                downtimes: taskDowntimes,
                                notifyParent: (List<Downtime> createdDowntimes) {
                                  taskDowntimes.addAll(createdDowntimes);
                                  setState(() {});
                                },
                                action: "create",
                              ),
                      ],
                    ),
                    errorCallback: () {})
                : SuperWidget(
                    childWidget: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Get Task Downtimes",
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
                          const Divider(
                            color: Colors.transparent,
                            height: 50.0,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: MaterialButton(
                                  onPressed: () async {
                                    Map<String, dynamic> conditions = {
                                      "EQUALS": {
                                        "Field": "code",
                                        "Value": jobCodeController.text,
                                      }
                                    };
                                    String jobID = "";
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await appStore.jobApp.list(conditions).then((response) async {
                                      if (response.containsKey("status") && response["status"]) {
                                        for (var item in response["payload"]) {
                                          Job thisJob = await Job.fromJSON(item);
                                          jobID = thisJob.id;
                                        }
                                        Map<String, dynamic> conditions = {
                                          "EQUALS": {
                                            "Field": "job_id",
                                            "Value": jobID,
                                          }
                                        };
                                        await appStore.taskApp.list(conditions).then((response) async {
                                          if (response.containsKey("status") && response["status"]) {
                                            Task task = await Task.fromJSON(response["payload"][0]);
                                            Map<String, dynamic> downtimeConditions = {
                                              "AND": [
                                                {
                                                  "EQUALS": {
                                                    "Field": "line_id",
                                                    "Value": task.line.id,
                                                  },
                                                },
                                                {
                                                  "OR": [
                                                    {
                                                      "BETWEEN": {
                                                        "Field": "start_time",
                                                        "LowerValue": task.startTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                                                        "HigherValue": task.endTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                                                      }
                                                    },
                                                    {
                                                      "BETWEEN": {
                                                        "Field": "end_time",
                                                        "LowerValue": task.startTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                                                        "HigherValue": task.endTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                                                      }
                                                    },
                                                    {
                                                      "IS": {
                                                        "Field": "end_time",
                                                        "Value": "NULL",
                                                      },
                                                    },
                                                  ],
                                                },
                                              ]
                                            };
                                            await appStore.downtimeApp.list(downtimeConditions).then((value) async {
                                              if (value.containsKey("status") && value["status"]) {
                                                for (var item in value["payload"]) {
                                                  Downtime downtime = await Downtime.fromJSON(item);
                                                  taskDowntimes.add(downtime);
                                                }
                                                setState(() {
                                                  isDataLoaded = true;
                                                });
                                              } else {
                                                setState(() {
                                                  errorMessage = "No Downtimes Found.";
                                                  isError = true;
                                                });
                                              }
                                            });
                                          } else {
                                            setState(() {
                                              errorMessage = "Task Not Found.";
                                              isError = true;
                                            });
                                          }
                                          setState(() {
                                            isLoading = false;
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          isLoading = false;
                                          isError = true;
                                          errorMessage = "Unable to Get Downtime Details";
                                        });
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
                                        builder: (BuildContext context) => const DowntimeListWidget(),
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
