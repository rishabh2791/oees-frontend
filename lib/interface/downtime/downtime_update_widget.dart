import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/downtime_preset.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/bool_form_field.dart';
import 'package:oees/interface/common/form_fields/date_form_field.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/form_fields/time_form_field.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/common/ui_elements/add_button.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class DowntimeUpdateWidget extends StatefulWidget {
  final Downtime downtime;
  final Function notifyParent;
  const DowntimeUpdateWidget({
    Key? key,
    required this.downtime,
    required this.notifyParent,
  }) : super(key: key);

  @override
  State<DowntimeUpdateWidget> createState() => _DowntimeUpdateWidgetState();
}

class _DowntimeUpdateWidgetState extends State<DowntimeUpdateWidget> {
  bool isLoading = true;
  bool isDowntimeError = false;
  String downtimeErrorMsg = "";
  List<DowntimePreset> presetDowntimes = [];
  Map<String, dynamic> map = {};
  int totalDowntime = 0, allocatedDowntime = 0;
  List<TextEditingController> descriptionControllers = [],
      startDateControllers = [],
      startTimeControllers = [],
      endDateControllers = [],
      endTimeControllers = [],
      plannedControllers = [],
      controlledControllers = [],
      presetControllers = [];
  late DateTime downtimeStartTime, downtimeEndTime, nowTime;
  List<BoolFormField> plannedFormFields = [], controlledFormFields = [];
  List<FormFieldWidget> mainFormWidgets = [];
  List<DropdownFormField> presetFormFields = [];
  List<TextFormFielder> descriptionFormFields = [];
  List<DateFormField> startDateFormFields = [], endDateFormFields = [];
  List<TimeFormField> startTimeFormFields = [], endTimeFormFields = [];

  @override
  void initState() {
    downtimeStartTime = DateTime(
      widget.downtime.startTime.year,
      widget.downtime.startTime.month,
      widget.downtime.startTime.day,
      widget.downtime.startTime.hour,
      widget.downtime.startTime.minute,
      0,
    );
    downtimeEndTime = DateTime(
      widget.downtime.endTime.year,
      widget.downtime.endTime.month,
      widget.downtime.endTime.day,
      widget.downtime.endTime.hour,
      widget.downtime.endTime.minute,
      0,
    );
    DateTime now = DateTime.now();
    nowTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      0,
    );
    totalDowntime = widget.downtime.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inMinutes < 0
        ? downtimeEndTime.difference(downtimeStartTime).inMinutes
        : nowTime.difference(widget.downtime.startTime).inMinutes;
    initData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  Future<void> initData() async {
    presetDowntimes = [];
    await Future.forEach([
      await getPresetDowntimes(),
    ], (element) {})
        .then((value) {
      initForm();
      descriptionControllers[0].text = widget.downtime.description;
      startDateControllers[0].text = widget.downtime.startTime.toLocal().toString().substring(0, 10);
      var startTime = widget.downtime.startTime;
      var endTime = widget.downtime.endTime;
      startTimeControllers[0].text = TimeOfDay(hour: startTime.hour, minute: startTime.minute).toString();
      endDateControllers[0].text = widget.downtime.endTime.toLocal().toString().substring(0, 10);
      endTimeControllers[0].text = TimeOfDay(hour: endTime.hour, minute: endTime.minute).toString();
      plannedControllers[0].text = widget.downtime.planned.toString();
      controlledControllers[0].text = widget.downtime.controlled.toString();
      setState(() {
        isLoading = false;
      });
    });
  }

  void initForm() {
    int period = 0;
    TextEditingController descriptionController = TextEditingController();
    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();
    TextEditingController plannedController = TextEditingController();
    TextEditingController controlledController = TextEditingController();
    TextEditingController presetController = TextEditingController();
    descriptionControllers.add(descriptionController);
    startDateControllers.add(startDateController);
    endDateControllers.add(endDateController);
    startTimeControllers.add(startTimeController);
    endTimeControllers.add(endTimeController);
    plannedControllers.add(plannedController);
    controlledControllers.add(controlledController);
    presetControllers.add(presetController);
    DropdownFormField presetFormField = DropdownFormField(
      formField: "preset",
      controller: presetController,
      dropdownItems: presetDowntimes,
      hint: "Select Preset Downtimes.",
      isRequired: false,
    );
    presetFormFields.add(presetFormField);
    TextFormFielder descriptionFormField = TextFormFielder(
      controller: descriptionController,
      formField: "description",
      label: "Downtime Description",
      minSize: 5,
      maxSize: 100,
      isRequired: true,
      disabled: false,
    );
    descriptionFormFields.add(descriptionFormField);
    DateFormField startDateFormField = DateFormField(
      controller: startDateController,
      formField: "start_date",
      hint: "Start Date",
      label: "Start Date",
      isRequired: true,
    );
    startDateFormFields.add(startDateFormField);
    DateFormField endDateFormField = DateFormField(
      controller: endDateController,
      formField: "end_date",
      hint: "End Date",
      label: "End Date",
      isRequired: true,
    );
    endDateFormFields.add(endDateFormField);
    TimeFormField startTimeFormField = TimeFormField(
      controller: startTimeController,
      formField: "start_time",
      hint: "Start Time",
      label: "Start Time",
      isRequired: true,
    );
    startTimeFormFields.add(startTimeFormField);
    TimeFormField endTimeFormField = TimeFormField(
      controller: endTimeController,
      formField: "end_time",
      hint: "End Time",
      label: "End Time",
      isRequired: true,
    );
    endTimeFormFields.add(endTimeFormField);
    BoolFormField controlledFormField = BoolFormField(
      label: "Controlled Downtime",
      formField: "controlled",
      selectedController: controlledController,
    );
    controlledFormFields.add(controlledFormField);
    BoolFormField plannedFormField = BoolFormField(
      label: "Planned Downtime",
      formField: "planned",
      selectedController: plannedController,
    );
    if (mainFormWidgets.isNotEmpty) {
      int length = mainFormWidgets.length;
      startDateController.text = endDateControllers[length - 1].text;
      endDateController.text = widget.downtime.endTime.toString().substring(0, 10);
      startTimeController.text = endTimeControllers[length - 1].text;
      endTimeController.text = TimeOfDay(hour: downtimeEndTime.hour, minute: downtimeEndTime.minute).toString();
    }
    plannedFormFields.add(plannedFormField);
    presetController.addListener(() {
      var presetDowntime = presetDowntimes.where((element) => element.id == presetController.text);
      if (presetDowntime.isNotEmpty) {
        period = presetDowntime.single.defaultPeriod;
        if (mainFormWidgets.length > 1) {
          startDateController.text = endDateControllers[endDateControllers.length - 2].text.toString().substring(0, 10);
          startTimeController.text = endTimeControllers[endTimeControllers.length - 2].text.toString();
        } else {
          startDateController.text = widget.downtime.startTime.toString().substring(0, 10);
          startTimeController.text = TimeOfDay(hour: widget.downtime.startTime.hour, minute: widget.downtime.startTime.minute).toString();
        }
        if (period > 0) {
          var startDate = startDateController.text;
          var time = ((startTimeController.text).split("(")[1]).split(")")[0];
          int hours = int.parse(time.split(":")[0].toString());
          int minutes = int.parse(time.split(":")[1].toString());
          var startDateTime = DateTime(int.parse(startDate.split("-")[0].toString()), int.parse(startDate.split("-")[1].toString()), int.parse(startDate.split("-")[2].toString()), hours, minutes);
          var endDateTime = startDateTime.add(Duration(seconds: period * 60));
          if (endDateTime.difference(widget.downtime.endTime).inSeconds > 0) {
            endDateTime = widget.downtime.endTime;
          }
          endDateController.text = endDateTime.toString().substring(0, 10);
          endTimeController.text = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute).toString();
          endTimeFormField.enabled = false;
          endDateFormField.enabled = false;
          controlledFormField.isEnabled = false;
          plannedFormField.isEnabled = false;
          setState(() {});
        }
        presetDowntime.single.type == "Controlled"
            ? changeState("0", "1", controlledController, plannedController)
            : presetDowntime.single.type == "Planned"
                ? changeState("1", "0", controlledController, plannedController)
                : changeState("0", "0", controlledController, plannedController);
      }
      allocatedDowntime = getAllocatedDowntime();
      setState(() {});
    });
    startTimeController.addListener(() {
      if (period != 0 && period * 60 < widget.downtime.endTime.difference(widget.downtime.startTime).inSeconds) {
        var startDate = startDateController.text;
        var time = ((startTimeController.text).split("(")[1]).split(")")[0];
        int hours = int.parse(time.split(":")[0].toString());
        int minutes = int.parse(time.split(":")[1].toString());
        var startDateTime = DateTime(int.parse(startDate.split("-")[0].toString()), int.parse(startDate.split("-")[1].toString()), int.parse(startDate.split("-")[2].toString()), hours, minutes);
        var endDateTime = startDateTime.add(Duration(seconds: period * 60));
        endDateController.text = endDateTime.toString().substring(0, 10);
        endTimeController.text = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute).toString();
        endTimeFormField.enabled = false;
        endDateFormField.enabled = false;
      }
    });
    descriptionController.addListener(() {
      allocatedDowntime = getAllocatedDowntime();
      setState(() {});
    });
    endTimeController.addListener(() {
      allocatedDowntime = getAllocatedDowntime();
      setState(() {});
    });
    List<FormFielder> formFields = [
      presetFormField,
      descriptionFormField,
      startDateFormField,
      startTimeFormField,
      endDateFormField,
      endTimeFormField,
    ];
    if (getAccessCode("tasks", "update") == "1") {
      formFields.addAll([
        plannedFormField,
        controlledFormField,
      ]);
    }
    FormFieldWidget mainFormWidget = FormFieldWidget(
      formFields: formFields,
      isVertical: false,
    );
    mainFormWidgets.add(mainFormWidget);
  }

  void changeState(String planned, String controlled, TextEditingController controlledController, TextEditingController plannedController) {
    controlledController.text = controlled;
    plannedController.text = planned;
  }

  int getAllocatedDowntime() {
    int totalAllocatedDowntime = 0;
    for (int i = 0; i < startDateControllers.length; i++) {
      var downtimeStartDate = startDateControllers[i].text;
      var downtimeStartTime = startTimeControllers[i].text;
      var downtimdEndDate = endDateControllers[i].text;
      var downtimeEndTime = endTimeControllers[i].text;
      var startTime = (downtimeStartTime.split("(")[1]).split(")")[0];
      int firstStartHours = int.parse(startTime.split(":")[0].toString());
      int firstStartMinutes = int.parse(startTime.split(":")[1].toString());
      var startDateTime = DateTime(int.parse(downtimeStartDate.split("-")[0].toString()), int.parse(downtimeStartDate.split("-")[1].toString()), int.parse(downtimeStartDate.split("-")[2].toString()),
          firstStartHours, firstStartMinutes);
      var endTime = ((downtimeEndTime).split("(")[1]).split(")")[0];
      int lastEndHours = int.parse(endTime.split(":")[0].toString());
      int lastEndMinutes = int.parse(endTime.split(":")[1].toString());
      var endDateTime = DateTime(
          int.parse(downtimdEndDate.split("-")[0].toString()), int.parse(downtimdEndDate.split("-")[1].toString()), int.parse(downtimdEndDate.split("-")[2].toString()), lastEndHours, lastEndMinutes);
      var thisDowntime = endDateTime.difference(startDateTime).inMinutes;
      totalAllocatedDowntime += thisDowntime;
    }
    return totalAllocatedDowntime;
  }

  List<Widget> renderForm() {
    List<Widget> widgets = [
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.arrow_back,
                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                size: 40.0,
              ),
            ),
          ),
          Text(
            "Update Downtime",
            style: TextStyle(
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const Divider(
        color: Colors.transparent,
        height: 50.0,
      ),
      Wrap(
        children: [
          Text(
            "Total Downtime: " + totalDowntime.toString().replaceAllMapped(reg, (Match match) => '${match[1]},') + " min",
            style: TextStyle(
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const VerticalDivider(
            width: 50,
            color: Colors.transparent,
          ),
          Text(
            "Total Allocated Downtime: " + allocatedDowntime.toString().replaceAllMapped(reg, (Match match) => '${match[1]},') + " min",
            style: TextStyle(
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const Divider(
        color: Colors.transparent,
        height: 50.0,
      ),
    ];
    List<Widget> rowWidgets = [];
    for (var form in mainFormWidgets) {
      rowWidgets.add(form.render());
    }
    widgets.add(Wrap(
      direction: Axis.horizontal,
      children: rowWidgets,
    ));
    widgets.add(
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MaterialButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                int totalAllocatedDowntime = 0;
                var firstStartDate = startDateControllers[0].text;
                var lastEndDate = (endDateControllers.last).text;
                var firstStartTime = startTimeControllers[0].text;
                var lastEndTime = (endTimeControllers.last).text;
                var startTime = ((firstStartTime).split("(")[1]).split(")")[0];
                int firstStartHours = int.parse(startTime.split(":")[0].toString());
                int firstStartMinutes = int.parse(startTime.split(":")[1].toString());
                var firstStartDateTime = DateTime(int.parse(firstStartDate.split("-")[0].toString()), int.parse(firstStartDate.split("-")[1].toString()),
                    int.parse(firstStartDate.split("-")[2].toString()), firstStartHours, firstStartMinutes);
                var endTime = ((lastEndTime).split("(")[1]).split(")")[0];
                int lastEndHours = int.parse(endTime.split(":")[0].toString());
                int lastEndMinutes = int.parse(endTime.split(":")[1].toString());
                var lastEndDateTime = DateTime(
                    int.parse(lastEndDate.split("-")[0].toString()), int.parse(lastEndDate.split("-")[1].toString()), int.parse(lastEndDate.split("-")[2].toString()), lastEndHours, lastEndMinutes);
                totalAllocatedDowntime = getAllocatedDowntime();
                if (totalDowntime != totalAllocatedDowntime) {
                  setState(() {
                    isLoading = false;
                    isDowntimeError = true;
                    downtimeErrorMsg = "Downtime not Fully Allocated.";
                  });
                  widget.notifyParent();
                }
                if (downtimeStartTime.difference(firstStartDateTime).inSeconds != 0) {
                  setState(() {
                    isLoading = false;
                    isDowntimeError = true;
                    downtimeErrorMsg = "First Downtime Start Time does not match with Downtime Start Time.";
                  });
                  widget.notifyParent();
                }
                if (downtimeEndTime.difference(lastEndDateTime).inSeconds != 0) {
                  setState(() {
                    isLoading = false;
                    isDowntimeError = true;
                    downtimeErrorMsg = "Last Downtime End Time does not match with Downtime End Time.";
                  });
                  widget.notifyParent();
                }
                if (!isDowntimeError) {
                  int lastIndex = mainFormWidgets.length - 1;
                  String creationErrors = "";
                  var updateFormWidget = mainFormWidgets[lastIndex];
                  var createFormWidgets = mainFormWidgets.getRange(0, lastIndex);
                  List<Map<String, dynamic>> downtimesToCreate = [];
                  for (FormFieldWidget downtimeForm in createFormWidgets) {
                    map = downtimeForm.toJSON();
                    map["created_by_username"] = currentUser.username;
                    map["updated_by_username"] = currentUser.username;
                    map["original_downtime_id"] = widget.downtime.id;
                    if (map.containsKey("planned") || map.containsKey("controlled")) {
                      map["planned"] = map["planned"] == "1" ? true : false;
                      map["controlled"] = map["controlled"] == "1" ? true : false;
                    } else {
                      if (map["preset"].isNotEmpty) {
                        DowntimePreset preset = presetDowntimes.firstWhere((element) => element.id == map["preset"]);
                        map["controlled"] = preset.type == "Controlled" ? true : false;
                        map["planned"] = preset.type == "Planned" ? true : false;
                      }
                    }
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

                    map["line_id"] = widget.downtime.line.id;
                    map.remove("start_date");
                    map.remove("end_date");
                    if (map["preset"].isEmpty && map["description"].isEmpty) {
                      creationErrors += "Downtime Description or Preset Not Set.\n";
                    } else {
                      downtimesToCreate.add(map);
                    }
                  }
                  List<Downtime> createdDowntimes = [];
                  if (creationErrors.isEmpty) {
                    await Future.forEach(downtimesToCreate, (Map<String, dynamic> map) async {
                      await appStore.downtimeApp.create(map).then((response) {
                        print(response);
                        if (response.containsKey("status") && response["status"]) {
                          Downtime createdDowntime = Downtime.fromJSON(response["payload"]);
                          createdDowntimes.add(createdDowntime);
                        } else {
                          if (response.containsKey("status")) {
                            creationErrors += response["message"];
                          } else {
                            creationErrors += "Unable to Create Downtime";
                          }
                        }
                      });
                    }).then((value) async {
                      if (creationErrors.isEmpty) {
                        var map = updateFormWidget.toJSON();
                        map["updated_by_username"] = currentUser.username;
                        if (map.containsKey("planned") || map.containsKey("controlled")) {
                          map["planned"] = map["planned"] == "1" ? true : false;
                          map["controlled"] = map["controlled"] == "1" ? true : false;
                        } else {
                          if (map["preset"].isNotEmpty) {
                            DowntimePreset preset = presetDowntimes.firstWhere((element) => element.id == map["preset"]);
                            map["controlled"] = preset.type == "Controlled" ? true : false;
                            map["planned"] = preset.type == "Planned" ? true : false;
                          }
                        }
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
                        map.remove("start_date");
                        map.remove("end_date");
                        await appStore.downtimeApp.update(widget.downtime.id, map).then((response) async {
                          if (response.containsKey("status") && response["status"]) {
                            setState(() {
                              isLoading = false;
                              updatingDowntime = true;
                              widget.downtime.description = presetControllers.last.text.isEmpty
                                  ? descriptionControllers.last.text
                                  : descriptionControllers.last.text.isEmpty
                                      ? presetDowntimes.firstWhere((element) => element.id == presetControllers.last.text).description
                                      : descriptionControllers.last.text;
                              widget.downtime.startTime = DateTime(
                                startDate.year,
                                startDate.month,
                                startDate.day,
                                int.parse(startTime.split(":")[0].toString()),
                                int.parse(startTime.split(":")[1].toString()),
                              );
                              widget.downtime.endTime = DateTime(
                                endDate.year,
                                endDate.month,
                                endDate.day,
                                int.parse(endTime.split(":")[0].toString()),
                                int.parse(endTime.split(":")[1].toString()),
                              );
                              widget.downtime.planned = map["planned"];
                              widget.downtime.controlled = map["controlled"];
                            });
                            widget.notifyParent(createdDowntimes);
                            setState(() {
                              isLoading = false;
                              updatingDowntime = false;
                            });
                            Navigator.of(context).pop();
                          } else {
                            if (response.containsKey("status")) {
                              setState(() {
                                isLoading = false;
                                errorMessage = response["message"];
                                isError = true;
                              });
                              widget.notifyParent();
                            } else {
                              setState(() {
                                isLoading = false;
                                errorMessage = "Unable to create downtime.";
                                isError = true;
                              });
                              widget.notifyParent();
                            }
                          }
                        });
                      } else {
                        setState(() {
                          isLoading = false;
                          isError = true;
                          errorMessage = creationErrors;
                        });
                      }
                    });
                  } else {
                    Navigator.of(context).pop();
                    setState(() {
                      isLoading = false;
                      isError = true;
                      errorMessage = creationErrors;
                    });
                  }
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
                descriptionControllers = [];
                startDateControllers = [];
                startTimeControllers = [];
                endDateControllers = [];
                endTimeControllers = [];
                plannedControllers = [];
                controlledControllers = [];
                presetControllers = [];
                plannedFormFields = [];
                controlledFormFields = [];
                mainFormWidgets = [];
                presetFormFields = [];
                descriptionFormFields = [];
                startDateFormFields = [];
                endDateFormFields = [];
                startTimeFormFields = [];
                endTimeFormFields = [];
                initData();
                setState(() {});
              },
              color: foregroundColor,
              height: 60.0,
              minWidth: 50.0,
              child: clearButton(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MaterialButton(
              onPressed: () {
                var lastEndDate = (endDateControllers.last).text;
                var lastEndTime = (endTimeControllers.last).text;
                var endTime = ((lastEndTime).split("(")[1]).split(")")[0];
                int lastEndHours = int.parse(endTime.split(":")[0].toString());
                int lastEndMinutes = int.parse(endTime.split(":")[1].toString());
                var lastEndDateTime = DateTime(
                    int.parse(lastEndDate.split("-")[0].toString()), int.parse(lastEndDate.split("-")[1].toString()), int.parse(lastEndDate.split("-")[2].toString()), lastEndHours, lastEndMinutes);
                if (lastEndDateTime != downtimeEndTime) {
                  initForm();
                }
                setState(() {});
              },
              color: foregroundColor,
              height: 60.0,
              minWidth: 50.0,
              child: addButton(),
            ),
          ),
        ],
      ),
    );
    widgets.add(
      const Divider(
        height: 40.0,
        color: Colors.transparent,
      ),
    );
    return widgets;
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
            : Scaffold(
                backgroundColor: isDarkTheme.value ? backgroundColor : foregroundColor,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: renderForm(),
                          ),
                        ),
                      ),
                    ),
                    isDowntimeError
                        ? DowntimeErrorDisplayWidget(
                            errorMessage: downtimeErrorMsg,
                            callback: () {
                              setState(() {
                                isLoading = false;
                                isDowntimeError = false;
                                downtimeErrorMsg = "";
                              });
                            },
                          )
                        : Container(),
                  ],
                ));
      },
    );
  }
}

class DowntimeErrorDisplayWidget extends StatefulWidget {
  final String errorMessage;
  final Function callback;
  const DowntimeErrorDisplayWidget({
    Key? key,
    required this.callback,
    required this.errorMessage,
  }) : super(key: key);

  @override
  State<DowntimeErrorDisplayWidget> createState() => _DowntimeErrorDisplayWidgetState();
}

class _DowntimeErrorDisplayWidgetState extends State<DowntimeErrorDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10.0,
        sigmaY: 10.0,
      ),
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 400,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  widget.errorMessage,
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Divider(
              height: 10.0,
              color: Colors.transparent,
            ),
            MaterialButton(
              onPressed: () {
                widget.callback();
              },
              color: Colors.green,
              height: 60.0,
              minWidth: 50.0,
              child: clearButton(),
            ),
          ],
        ),
      ),
    );
  }
}
