import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/downtime_preset.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';
import 'package:oees/interface/downtime/downtime_list.dart';

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
  List<Downtimes> downtimes = [];
  List<DowntimePreset> presetDowntimes = [];
  Map<String, dynamic> map = {};
  int totalDowntime = 0, allocatedDowntime = 0;
  List<TextEditingController> presetControllers = [];
  late DateTime downtimeStartTime, downtimeEndTime, nowTime;
  List<FormFieldWidget> mainFormWidgets = [];
  List<DropdownFormField> presetFormFields = [];

  @override
  void initState() {
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
        presetDowntimes.sort((a, b) => a.description.compareTo(b.description));
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
    totalDowntime = widget.downtime.endTime.toUtc().difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0
        ? downtimeEndTime.difference(downtimeStartTime).inMinutes
        : nowTime.difference(widget.downtime.startTime).inMinutes;
    await Future.forEach([
      await getPresetDowntimes(),
    ], (element) {})
        .then((value) {
      initForm();
      setState(() {
        isLoading = false;
      });
    });
  }

  void initForm() {
    TextEditingController presetController = TextEditingController();
    presetControllers.add(presetController);
    DropdownFormField presetFormField = DropdownFormField(
      formField: "preset",
      controller: presetController,
      dropdownItems: presetDowntimes,
      hint: "Select Preset Downtimes.",
      isRequired: false,
    );
    presetFormFields.add(presetFormField);
    presetController.addListener(() {
      var presetDowntime = presetDowntimes.where((element) => element.id == presetController.text);
      if (presetDowntimes.isNotEmpty) {
        var thisDowntimeStartTime = downtimeStartTime;
        var thisDowntimeEndTime = downtimeEndTime;
        var calculatedDowntimeEndTime = thisDowntimeStartTime.add(Duration(minutes: presetDowntime.single.defaultPeriod));
        if (calculatedDowntimeEndTime.difference(downtimeEndTime).inMinutes < 0) {
          thisDowntimeEndTime = calculatedDowntimeEndTime;
        } else {
          thisDowntimeEndTime = downtimeEndTime;
        }
        Downtimes thisDowntime = Downtimes(
          preset: presetDowntime.single,
          startTime: thisDowntimeStartTime,
          endTime: thisDowntimeEndTime,
        );
        downtimes.add(thisDowntime);
        downtimeStartTime = thisDowntimeEndTime;
      }

      presetController.text = "";

      getAllocatedDowntime();
      setState(() {});
    });
    List<FormFielder> formFields = [
      presetFormField,
    ];
    FormFieldWidget mainFormWidget = FormFieldWidget(
      formFields: formFields,
      isVertical: false,
    );
    mainFormWidgets.add(mainFormWidget);
  }

  void getAllocatedDowntime() {
    int totalAllocatedDowntime = 0;
    for (int i = 0; i < downtimes.length; i++) {
      var downtimeStartTime = downtimes[i].startTime;
      var downtimeEndTime = downtimes[i].endTime;
      var thisDowntime = downtimeEndTime.difference(downtimeStartTime).inMinutes;
      totalAllocatedDowntime += thisDowntime;
    }
    allocatedDowntime = totalAllocatedDowntime;
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

    errorMessage.isNotEmpty
        ? widgets.add(Text(
            errorMessage,
            style: TextStyle(
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontSize: 20,
            ),
          ))
        : Container();

    widgets.add(
      const Divider(
        color: Colors.transparent,
        height: 50.0,
      ),
    );

    List<Widget> formRowWidgets = [];
    for (var form in mainFormWidgets) {
      formRowWidgets.add(form.render());
    }

    if (downtimeEndTime.difference(downtimeStartTime).inMinutes > 0) {
      widgets.add(Wrap(
        direction: Axis.horizontal,
        children: formRowWidgets,
      ));
    }

    if (downtimes.isNotEmpty) {
      widgets.add(
        DowntimeList(downtimes: downtimes),
      );
    }

    widgets.add(
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MaterialButton(
              onPressed: () async {
                setState(() {
                  // isLoading = true;
                  errorMessage = "";
                });
                if (totalDowntime != allocatedDowntime) {
                  setState(() {
                    errorMessage = "Downtimes not fully allocated";
                  });
                } else {
                  List<Downtimes> toCreate = downtimes.length > 1 ? downtimes.getRange(0, downtimes.length - 1).toList() : [];
                  Downtimes toUpdate = downtimes.last;
                  List<Downtime> createdDowntimes = [];
                  String creationErrors = "";

                  Map<String, dynamic> update = {
                    "start_time": toUpdate.startTime.toUtc().toString().substring(0, 10) + "T" + toUpdate.startTime.toUtc().toString().substring(11, 19) + "Z",
                    "end_time": toUpdate.endTime.toUtc().toString().substring(0, 10) + "T" + toUpdate.endTime.toUtc().toString().substring(11, 19) + "Z",
                    "planned": toUpdate.preset.type == "Planned" ? true : false,
                    "controlled": toUpdate.preset.type == "Controlled" ? true : false,
                    "preset": toUpdate.preset.id,
                    "description": toUpdate.preset.description,
                    "updated_by_username": currentUser.username,
                  };

                  await appStore.downtimeApp.update(widget.downtime.id, update).then((updateResponse) async {
                    if (updateResponse.containsKey("status") && updateResponse["status"]) {
                      widget.downtime.description = toUpdate.preset.description;
                      widget.downtime.startTime = toUpdate.startTime;
                      widget.downtime.endTime = toUpdate.endTime;
                      if (toCreate.isNotEmpty) {
                        await Future.forEach(toCreate, (Downtimes element) async {
                          Map<String, dynamic> createdDowntime = {
                            "line_id": widget.downtime.line.id,
                            "planned": element.preset.type == "Planned" ? true : false,
                            "controlled": element.preset.type == "Controlled" ? true : false,
                            "start_time": element.startTime.toUtc().toString().substring(0, 10) + "T" + element.startTime.toUtc().toString().substring(11, 19) + "Z",
                            "end_time": element.endTime.toUtc().toString().substring(0, 10) + "T" + element.endTime.toUtc().toString().substring(11, 19) + "Z",
                            "preset": element.preset.id,
                            "original_downtime_id": widget.downtime.id,
                            "description": element.preset.description,
                            "updated_by_username": currentUser.username,
                          };
                          await appStore.downtimeApp.create(createdDowntime).then((response) async {
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
                          if (creationErrors.isNotEmpty) {
                            setState(() {
                              errorMessage = creationErrors;
                            });
                          }
                          widget.notifyParent(createdDowntimes);
                          Navigator.of(context).pop();
                        });
                      }
                    } else {
                      if (updateResponse.containsKey("status")) {
                        setState(() {
                          errorMessage = updateResponse["message"];
                        });
                      } else {
                        setState(() {
                          errorMessage = "Unable to Update Downtime";
                        });
                      }
                      widget.notifyParent(createdDowntimes);
                      Navigator.of(context).pop();
                    }
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
                presetControllers = [];
                mainFormWidgets = [];
                presetFormFields = [];
                downtimes = [];
                errorMessage = "";
                initData();
                getAllocatedDowntime();
                setState(() {});
              },
              color: foregroundColor,
              height: 60.0,
              minWidth: 50.0,
              child: clearButton(),
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

class Downtimes {
  final DowntimePreset preset;
  final DateTime startTime;
  final DateTime endTime;

  Downtimes({
    required this.preset,
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() {
    return preset.description + " - " + startTime.toLocal().toString().substring(0, 16) + " - " + endTime.toLocal().toString().substring(0, 16);
  }
}
