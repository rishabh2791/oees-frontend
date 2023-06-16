import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/date_form_field.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/lists/downtime.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class LineDowntimeListWidget extends StatefulWidget {
  const LineDowntimeListWidget({Key? key}) : super(key: key);

  @override
  State<LineDowntimeListWidget> createState() => _LineDowntimeListWidgetState();
}

class _LineDowntimeListWidgetState extends State<LineDowntimeListWidget> {
  bool isLoading = true;
  bool isLineSelected = false;
  List<Line> lines = [];
  List<Downtime> downtimes = [];
  late Map<String, dynamic> map;
  late FormFieldWidget formFieldWidget;
  late DropdownFormField lineFormField;
  late DateFormField startDateFormWidget, endDataFormWidget;
  late TextEditingController startDateController, endDateController, lineController;

  @override
  void initState() {
    getLines();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    lineController = TextEditingController();
    super.initState();
  }

  Future<void> getLines() async {
    lines = [];
    await appStore.lineApp.list({}).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Line line = await Line.fromJSON(item);
          lines.add(line);
        }
        lines.sort((a, b) => a.name.compareTo(b.name));
      }
      initForm();
      setState(() {
        isLoading = false;
      });
    });
  }

  refresh(List<Downtime> createdDowntimes) {
    downtimes.addAll(createdDowntimes);
    if (updatingDowntime) {
      setState(() {});
    }
  }

  void initForm() {
    startDateFormWidget = DateFormField(
      controller: startDateController,
      formField: "start_date",
      hint: "Start Date",
      label: "Start Date",
    );
    endDataFormWidget = DateFormField(
      controller: endDateController,
      formField: "end_date",
      hint: "End Date",
      label: "End Date",
    );
    lineFormField = DropdownFormField(
      formField: "line_id",
      controller: lineController,
      dropdownItems: lines,
      hint: "Select Line",
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        lineFormField,
        startDateFormWidget,
        endDataFormWidget,
      ],
    );
  }

  Widget selectionWidget() {
    Widget widget = Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "View Downtimes",
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
                    map = formFieldWidget.toJSON();
                    if (formFieldWidget.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      Map<String, dynamic> conditions = {
                        "AND": [
                          {
                            "EQUALS": {
                              "Field": "line_id",
                              "Value": lineController.text,
                            },
                          },
                          {
                            "OR": [
                              {
                                "BETWEEN": {
                                  "Field": "start_time",
                                  "LowerValue": DateTime.parse(map["start_date"]).toUtc().toIso8601String().toString().split(".")[0] + "Z",
                                  "HigherValue": DateTime.parse(map["end_date"]).add(const Duration(days: 1)).toUtc().toIso8601String().toString().split(".")[0] + "Z",
                                }
                              },
                              {
                                "BETWEEN": {
                                  "Field": "end_time",
                                  "LowerValue": DateTime.parse(map["start_date"]).toUtc().toIso8601String().toString().split(".")[0] + "Z",
                                  "HigherValue": DateTime.parse(map["end_date"]).add(const Duration(days: 1)).toUtc().toIso8601String().toString().split(".")[0] + "Z",
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
                      await appStore.downtimeApp.list(conditions).then((value) async {
                        if (value.containsKey("status") && value["status"]) {
                          for (var item in value["payload"]) {
                            Downtime downtime = await Downtime.fromJSON(item);
                            downtimes.add(downtime);
                          }
                          downtimes.sort(((a, b) => a.createdAt.compareTo(b.createdAt)));
                          setState(() {
                            isLoading = false;
                            isLineSelected = true;
                          });
                        } else {
                          setState(() {
                            isLoading = false;
                            errorMessage = "Unable to get Downtime Data for Line.";
                            isError = true;
                          });
                        }
                      });
                    } else {
                      setState(() {
                        isError = true;
                        errorMessage = "Invalid Form Values";
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
                        builder: (BuildContext context) => const LineDowntimeListWidget(),
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
    );
    return widget;
  }

  Widget displayWidget() {
    Widget widget = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Downtimes",
          style: TextStyle(
            color: isDarkTheme.value ? foregroundColor : backgroundColor,
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        downtimes.isEmpty
            ? Text(
                "No Downtimes Found",
                style: TextStyle(
                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            : DowntimeList(downtimes: downtimes, notifyParent: refresh),
      ],
    );
    return widget;
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
                childWidget: isLineSelected ? displayWidget() : selectionWidget(),
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
