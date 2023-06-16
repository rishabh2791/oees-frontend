import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/downtime_preset.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/bool_form_field.dart';
import 'package:oees/interface/common/form_fields/date_form_field.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/form_fields/time_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class DowntimeCreateWidget extends StatefulWidget {
  const DowntimeCreateWidget({Key? key}) : super(key: key);

  @override
  State<DowntimeCreateWidget> createState() => _DowntimeCreateWidgetState();
}

class _DowntimeCreateWidgetState extends State<DowntimeCreateWidget> {
  bool isLoading = true;
  bool isDataLoaded = false;
  int period = 0;
  List<Line> lines = [];
  List<DowntimePreset> presetDowntimes = [];
  Map<String, dynamic> map = {};
  late TextEditingController lineController,
      descriptionController,
      startDateController,
      startTimeController,
      endDateController,
      endTimeController,
      plannedController,
      controlledController,
      presetController;
  late BoolFormField plannedFormField, controlledFormField;
  late FormFieldWidget mainFormWidget;
  late DropdownFormField lineFormField, presetFormField;
  late TextFormFielder descriptionFormField;
  late DateFormField startDateFormField, endDateFormField;
  late TimeFormField startTimeFormField, endTimeFormField;

  @override
  void initState() {
    lineController = TextEditingController();
    descriptionController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
    plannedController = TextEditingController();
    controlledController = TextEditingController();
    presetController = TextEditingController();
    getDetails();
    super.initState();
    presetController.addListener(autoFill);
    startTimeController.addListener(changeEndTime);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getDetails() async {
    setState(() {
      isLoading = true;
    });
    await Future.forEach([
      await getLines(),
      await getPresetDowntimes(),
    ], (element) {
      initForm();
      setState(() {
        isLoading = false;
        isDataLoaded = true;
      });
    });
  }

  Future<void> getLines() async {
    await appStore.lineApp.list({}).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Line line = await Line.fromJSON(item);
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

  Future<void> getPresetDowntimes() async {
    await appStore.downtimePresetApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          DowntimePreset downtimePreset = DowntimePreset.fromJSON(item);
          presetDowntimes.add(downtimePreset);
        }
      } else {
        setState(() {
          errorMessage = "Unable to get Preset Downtimes.";
          isError = true;
        });
      }
    });
  }

  void initForm() {
    presetFormField = DropdownFormField(
      formField: "preset",
      controller: presetController,
      dropdownItems: presetDowntimes,
      hint: "Select Preset Downtimes.",
    );
    descriptionFormField = TextFormFielder(
      controller: descriptionController,
      formField: "description",
      label: "Downtime Description",
      minSize: 5,
      maxSize: 100,
    );
    startDateFormField = DateFormField(
      controller: startDateController,
      formField: "start_date",
      hint: "Start Date",
      label: "Start Date",
    );
    endDateFormField = DateFormField(
      controller: endDateController,
      formField: "end_date",
      hint: "End Date",
      label: "End Date",
      isRequired: false,
    );
    startTimeFormField = TimeFormField(
      controller: startTimeController,
      formField: "start_time",
      hint: "Start Time",
      label: "Start Time",
    );
    endTimeFormField = TimeFormField(
      controller: endTimeController,
      formField: "end_time",
      hint: "End Time",
      label: "End Time",
      isRequired: false,
    );
    lineFormField = DropdownFormField(
      formField: "line_id",
      controller: lineController,
      dropdownItems: lines,
      hint: "Line",
    );
    controlledFormField = BoolFormField(
      label: "Controller Downtime",
      formField: "controlled",
      selectedController: controlledController,
    );
    plannedFormField = BoolFormField(
      label: "Planned Downtime",
      formField: "planned",
      selectedController: plannedController,
    );
    mainFormWidget = FormFieldWidget(
      formFields: [
        lineFormField,
        descriptionFormField,
        startDateFormField,
        startTimeFormField,
        endDateFormField,
        endTimeFormField,
        plannedFormField,
        controlledFormField,
      ],
    );
  }

  void autoFill() {
    var presetDowntime = presetDowntimes.where((element) => element.id == presetController.text);
    if (presetDowntime.isNotEmpty) {
      DateTime now = DateTime.now();
      descriptionController.text = presetDowntime.single.description;
      period = presetDowntime.single.defaultPeriod;
      startDateController.text = now.toString().substring(0, 10);
      startTimeController.text = TimeOfDay(hour: now.hour, minute: now.minute).toString();
      endTimeFormField.enabled = false;
      endDateFormField.enabled = false;
      presetDowntime.single.type == "Controlled"
          ? changeState("0", "1")
          : presetDowntime.single.type == "Planned"
              ? changeState("1", "0")
              : changeState("0", "0");
      setState(() {});
    }
  }

  void changeState(String planned, String controlled) {
    controlledController.text = controlled;
    plannedController.text = planned;
  }

  void changeEndTime() {
    if (period != 0) {
      var startDate = startDateController.text;
      var time = ((startTimeController.text).split("(")[1]).split(")")[0];
      int hours = int.parse(time.split(":")[0].toString());
      int minutes = int.parse(time.split(":")[1].toString());
      var startDateTime = DateTime(int.parse(startDate.split("-")[0].toString()), int.parse(startDate.split("-")[1].toString()), int.parse(startDate.split("-")[2].toString()), hours, minutes);
      var endDateTime = startDateTime.add(Duration(minutes: period));
      endDateController.text = endDateTime.toString().substring(0, 10);
      endTimeController.text = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute).toString();
    }
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
                        "Create Downtime",
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
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: presetFormField.render(),
                            )
                          : Container(),
                      isDataLoaded ? mainFormWidget.render() : Container(),
                      isDataLoaded
                          ? Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: MaterialButton(
                                    onPressed: () async {
                                      if (mainFormWidget.validate()) {
                                        map = mainFormWidget.toJSON();
                                        map["created_by_username"] = currentUser.username;
                                        map["updated_by_username"] = currentUser.username;
                                        map["planned"] = map["planned"] == "1" ? true : false;
                                        map["controlled"] = map["controlled"] == "1" ? true : false;
                                        DateTime startDate = DateTime.parse(map["start_date"]);
                                        String startTime = ((map["start_time"].split("(")[1]).split(")")[0]);
                                        map["start_time"] = DateTime(
                                              startDate.year,
                                              startDate.month,
                                              startDate.day,
                                              int.parse(startTime.split(":")[0].toString()),
                                              int.parse(startTime.split(":")[1].toString()),
                                            ).toUtc().toIso8601String().toString().split(".")[0] +
                                            "Z";
                                        if (map.containsKey("end_date")) {
                                          DateTime endDate = DateTime.parse(map["end_date"]);
                                          String endTime = ((map["end_time"].split("(")[1]).split(")")[0]);
                                          map["end_time"] = DateTime(
                                                endDate.year,
                                                endDate.month,
                                                endDate.day,
                                                int.parse(endTime.split(":")[0].toString()),
                                                int.parse(endTime.split(":")[1].toString()),
                                              ).toUtc().toIso8601String().toString().split(".")[0] +
                                              "Z";
                                        }

                                        map.remove("start_date");
                                        map.remove("end_date");
                                        await appStore.downtimeApp.create(map).then((response) {
                                          if (response.containsKey("status") && response["status"]) {
                                            setState(() {
                                              errorMessage = "Downtime Created";
                                              isError = true;
                                            });
                                            navigationService.push(
                                              CupertinoPageRoute(
                                                builder: (BuildContext context) => const DowntimeCreateWidget(),
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
                                                errorMessage = "Unable to create downtime.";
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
                                          builder: (BuildContext context) => const DowntimeCreateWidget(),
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
