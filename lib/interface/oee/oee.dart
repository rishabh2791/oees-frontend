import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/device.dart';
import 'package:oees/domain/entity/device_data.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/date_form_field.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/hourly_series/bad.dart';
import 'package:oees/interface/common/hourly_series/controlled.dart';
import 'package:oees/interface/common/hourly_series/good.dart';
import 'package:oees/interface/common/hourly_series/planned.dart';
import 'package:oees/interface/common/hourly_series/unplanned.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';
import 'package:oees/interface/common/lists/oee_list.dart';

class OEE extends StatefulWidget {
  const OEE({Key? key}) : super(key: key);

  @override
  State<OEE> createState() => _OEEState();
}

class _OEEState extends State<OEE> {
  List<Line> lines = [];
  bool isLoading = true;
  bool isDataLoaded = false;
  List<String> lineIDs = [];
  List<String> skuIDs = [];
  List<String> deviceIDs = [];
  Map<String, String> lineIP = {};
  Map<String, double> skuSpeeds = {};
  Map<String, List<Task>> tasksByLine = {};
  Map<String, List<SKU>> skusByLine = {};
  Map<String, List<Downtime>> downtimeByLine = {};
  Map<String, List<Device>> devicesByLine = {};
  late TextEditingController startController, endController;
  late DropdownFormField lineSelectionFormField;
  Map<String, List<DeviceData>> deviceDataByLine = {};
  Map<String, double> lineAvailability = {}, linePerformance = {}, lineQuality = {}, lineOEE = {};
  Map<String, double> theoreticalProduction = {}, actualProduction = {}, controlledDowntimes = {}, plannedDowntimes = {}, unplannedDowntimes = {};
  Map<String, List<ControlledDowntime>> controlledDowntimeSeries = {};
  Map<String, List<PlannedDowntime>> plannedDowntimeSeries = {};
  Map<String, List<UnplannedDowntime>> unplannedDowntimeSeries = {};
  Map<String, List<GoodRateProduction>> goodRateSeries = {};
  Map<String, List<BadRateProduction>> badRateSeries = {};
  Map<String, DateTime> lineRunningTaskStartTime = {};
  late FormFieldWidget formFieldWidget;
  late DateFormField startDateFormWidget, endDataFormWidget;
  late Map<String, dynamic> map;
  late DropdownFormField lineFormField;
  late DateTime startTime, endTime;
  List<LineOEE> lineOEEs = [];
  double factoryRunTime = 0, factoryControlledDowntime = 0, factoryPlannedDowntime = 0, factoryUnplannedDowntime = 0, factoryExpectedProduction = 0, factoryActualProduction = 0;

  @override
  void initState() {
    getLines();
    startController = TextEditingController();
    endController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getLines() async {
    lines = [];
    await appStore.lineApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Line line = Line.fromJSON(item);
          lines.add(line);
          if (!lineIDs.contains(line.id)) {
            lineIDs.add(line.id);
          }
          lines.sort((a, b) => a.name.compareTo(b.name));
          initForm();
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }

  void initForm() {
    startDateFormWidget = DateFormField(
      controller: startController,
      formField: "start_date",
      hint: "Start Date",
      label: "Start Date",
    );
    endDataFormWidget = DateFormField(
      controller: endController,
      formField: "end_date",
      hint: "End Date",
      label: "End Date",
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        startDateFormWidget,
        endDataFormWidget,
      ],
    );
  }

  Future<void> getBackendData() async {
    setState(() {
      isLoading = true;
    });
    if (lines.isNotEmpty) {
      if (lines.isEmpty) {
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage = "No Lines Found";
        });
      } else {
        await Future.forEach([
          await getDowntimes(),
          await getTasks(),
        ], (element) {})
            .then((value) async {
          if (skuIDs.isEmpty) {
            setState(() {
              isLoading = false;
              isError = true;
              errorMessage = "SKUs not Found.";
            });
          } else {
            await Future.wait([
              getDevices(),
            ]).then((value) async {
              if (skuSpeeds.isEmpty || deviceIDs.isEmpty) {
                setState(() {
                  isLoading = false;
                });
              } else {
                await Future.forEach(
                  [
                    await getDeviceData(),
                  ],
                  (element) {},
                ).then((value) async {
                  getRunEfficiency();
                }).then((value) async {
                  for (var line in lines) {
                    LineOEE thisLineOEE = LineOEE(
                      availability: lineAvailability[line.id] ?? 0,
                      lineName: line.name,
                      oee: lineOEE[line.id] ?? 0,
                      performance: linePerformance[line.id] ?? 0,
                      quality: lineQuality[line.id] ?? 0,
                    );
                    lineOEEs.add(thisLineOEE);
                  }
                  lineOEEs.sort((a, b) => a.lineName.compareTo(b.lineName));
                  setState(() {
                    isDataLoaded = true;
                    isLoading = false;
                  });
                });
              }
            });
          }
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getDowntimes() async {
    downtimeByLine = {};
    await Future.wait(lines.map(
      (line) async {
        Map<String, dynamic> conditions = {
          "AND": [
            {
              "EQUALS": {
                "Field": "line_id",
                "Value": line.id,
              },
            },
            {
              "OR": [
                {
                  "BETWEEN": {
                    "Field": "start_time",
                    "LowerValue": startTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                    "HigherValue": endTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                  }
                },
                {
                  "BETWEEN": {
                    "Field": "end_time",
                    "LowerValue": startTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                    "HigherValue": endTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
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
        await appStore.downtimeApp.list(conditions).then((response) {
          if (response.containsKey("status") && response["status"]) {
            for (var item in response["payload"]) {
              Downtime downtime = Downtime.fromJSON(item);
              if (downtimeByLine.containsKey(line.id)) {
                downtimeByLine[line.id]!.add(downtime);
              } else {
                downtimeByLine[line.id] = [downtime];
              }
            }
          }
        });
      },
    ));
  }

  Future<void> getTasks() async {
    Map<String, dynamic> conditions = {
      "AND": [
        {
          "IN": {
            "Field": "line_id",
            "Value": lineIDs,
          },
        },
        {
          "OR": [
            {
              "BETWEEN": {
                "Field": "start_time",
                "LowerValue": startTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                "HigherValue": endTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
              }
            },
            {
              "BETWEEN": {
                "Field": "end_time",
                "LowerValue": startTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                "HigherValue": endTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
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
    await appStore.taskApp.list(conditions).then((response) {
      if (response.containsKey("status") && response["status"]) {
        tasksByLine = {};
        skusByLine = {};
        skuSpeeds = {};
        for (var item in response["payload"]) {
          Task task = Task.fromJSON(item);
          if (!skuSpeeds.containsKey(task.line.id + "_" + task.job.sku.id)) {
            skuSpeeds[task.line.id + "_" + task.job.sku.id] = double.parse(task.line.speedType == 1 ? task.job.sku.lowRunSpeed.toString() : task.job.sku.highRunSpeed.toString());
          }
          if (task.startTime.toLocal().difference(DateTime.parse("1900-01-01T00:00:00Z").toLocal()).inSeconds > 0) {
            if (tasksByLine.containsKey(task.line.id)) {
              tasksByLine[task.line.id]!.add(task);
            } else {
              tasksByLine[task.line.id] = [task];
            }
            if (skusByLine.containsKey(task.line.id)) {
              skusByLine[task.line.id]!.add(task.job.sku);
            } else {
              skusByLine[task.line.id] = [task.job.sku];
            }
            if (!skuIDs.contains(task.job.sku.id)) {
              skuIDs.add(task.job.sku.id);
            }
          }
        }
      }
    });
  }

  Future<void> getDevices() async {
    Map<String, dynamic> conditions = {
      "IN": {
        "Field": "line_id",
        "Value": lineIDs,
      }
    };
    await appStore.deviceApp.list(conditions).then((response) {
      if (response.containsKey("status") && response["status"]) {
        devicesByLine = {};
        for (var item in response["payload"]) {
          Device device = Device.fromJSON(item);
          if (device.useForOEE) {
            if (devicesByLine.containsKey(device.line.id)) {
              devicesByLine[device.line.id]!.add(device);
            } else {
              devicesByLine[device.line.id] = [device];
            }
            if (!deviceIDs.contains(device.id)) {
              deviceIDs.add(device.id);
            }
          }
        }
      }
    });
  }

  Future<void> getDeviceData() async {
    Map<String, dynamic> conditions = {
      "AND": [
        {
          "IN": {
            "Field": "device_id",
            "Value": deviceIDs,
          },
        },
        {
          "BETWEEN": {
            "Field": "created_at",
            "LowerValue": startTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
            "HigherValue": endTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
          }
        },
      ]
    };
    await appStore.deviceDataApp.list(conditions).then((response) {
      if (response.containsKey("status") && response["status"]) {
        deviceDataByLine = {};
        for (var item in response["payload"]) {
          DeviceData deviceData = DeviceData.fromJSON(item);
          if (deviceDataByLine.containsKey(deviceData.device.line.id)) {
            deviceDataByLine[deviceData.device.line.id]!.add(deviceData);
          } else {
            deviceDataByLine[deviceData.device.line.id] = [deviceData];
          }
        }
      }
    });
  }

  getRunEfficiency() {
    actualProduction = {};
    theoreticalProduction = {};
    controlledDowntimes = {};
    plannedDowntimes = {};
    unplannedDowntimes = {};
    for (var lineID in lineIDs) {
      double lineTotalTime = 0, lineTotalControlledDowntime = 0, lineTotalPlannedDowntime = 0, lineTotalUnplannedDowntime = 0;
      lineTotalTime = (endTime.difference(startTime).inSeconds).toDouble();
      factoryRunTime += lineTotalTime;
      lineTotalControlledDowntime = getTotalDowntime(startTime, endTime, lineID, "Controlled").toDouble();
      factoryControlledDowntime += lineTotalControlledDowntime;
      lineTotalPlannedDowntime = getTotalDowntime(startTime, endTime, lineID, "Planned").toDouble();
      factoryPlannedDowntime += lineTotalPlannedDowntime;
      lineTotalUnplannedDowntime = getTotalDowntime(startTime, endTime, lineID, "Unplanned").toDouble();
      factoryUnplannedDowntime += lineTotalUnplannedDowntime;
      double linePeriodProduction = getTheoreticalTotalProduction(startTime, endTime, lineID);
      factoryExpectedProduction += linePeriodProduction;
      double actualPeriodProduction = getActualTotalDeviceData(startTime, endTime, lineID);
      factoryActualProduction += actualPeriodProduction;
      actualProduction[lineID] = actualPeriodProduction;
      theoreticalProduction[lineID] = linePeriodProduction;
      controlledDowntimes[lineID] = lineTotalControlledDowntime;
      plannedDowntimes[lineID] = lineTotalPlannedDowntime;
      unplannedDowntimes[lineID] = lineTotalUnplannedDowntime;

      lineAvailability[lineID] = (lineTotalTime - lineTotalControlledDowntime - lineTotalPlannedDowntime - lineTotalUnplannedDowntime) / (lineTotalTime - lineTotalControlledDowntime);
      linePerformance[lineID] = min(1, linePeriodProduction == 0 ? 0 : (actualPeriodProduction / linePeriodProduction));
      lineQuality[lineID] = 1;
      lineOEE[lineID] = linePeriodProduction == 0 ? 0 : lineAvailability[lineID]! * linePerformance[lineID]! * 1;
    }
    double factoryAvailability = (factoryRunTime - factoryControlledDowntime - factoryPlannedDowntime - factoryUnplannedDowntime) / (factoryRunTime - factoryControlledDowntime);
    double factoryPerformance = min(1, factoryExpectedProduction == 0 ? 0 : (factoryActualProduction / factoryExpectedProduction));
    double factoryQuality = 1;
    double factoryOEE = factoryExpectedProduction == 0 ? 0 : factoryAvailability * factoryPerformance * factoryQuality;
    lineOEEs.add(LineOEE(availability: factoryAvailability, lineName: "'Factory'", oee: factoryOEE, performance: factoryPerformance, quality: factoryQuality));
  }

  double getTheoreticalTotalProduction(DateTime startTime, DateTime endTime, String lineID) {
    double production = 0;
    if (tasksByLine.containsKey(lineID)) {
      for (var task in tasksByLine[lineID]!) {
        DateTime taskStartTime = task.startTime.difference(startTime).inSeconds < 0 ? startTime : task.startTime;
        DateTime taskEndTime = task.endTime.difference(endTime).inSeconds > 0 ? endTime : task.endTime;
        int taskTime = taskEndTime.difference(taskStartTime).inSeconds;
        int totalControlledDowntime = getTotalDowntime(taskStartTime, taskEndTime, lineID, "Controlled");
        int totalPlannedDowntime = getTotalDowntime(taskStartTime, taskEndTime, lineID, "Planned");
        int totalUnplannedDowntime = getTotalDowntime(taskStartTime, taskEndTime, lineID, "Unplanned");
        int totalProductionTime = taskTime - totalControlledDowntime - totalPlannedDowntime - totalUnplannedDowntime;
        var speed = skuSpeeds[lineID + "_" + task.job.sku.id] ?? 0;
        double taskProduction = speed * double.parse(totalProductionTime.toString()) / 60;
        production += taskProduction;
      }
    }
    return production;
  }

  double getActualTotalDeviceData(DateTime startTime, DateTime endTime, String lineID) {
    double production = 0;
    if (deviceDataByLine.containsKey(lineID)) {
      for (var deviceData in deviceDataByLine[lineID]!) {
        if (deviceData.createdAt.difference(startTime).inSeconds > 0 && deviceData.createdAt.difference(endTime).inSeconds < 0) {
          production += deviceData.value;
        }
      }
    }
    return production;
  }

  int getTotalDowntime(DateTime startTime, DateTime endTime, String lineID, String type) {
    int totalDowntime = 0;
    List<Downtime> downtimes = downtimeByLine[lineID] ?? [];
    if (downtimes.isEmpty) {
      return 0;
    } else {
      for (var downtime in downtimes) {
        if ((downtime.endTime.difference(startTime).inSeconds < 0) || (downtime.startTime.difference(endTime).inSeconds > 0)) {
          //do nothing
        } else {
          DateTime downtimeStartTime = downtime.startTime.difference(startTime).inSeconds < 0 ? startTime : downtime.startTime;
          DateTime downtimeEndTime = downtime.endTime.difference(DateTime.now()).inSeconds > 0
              ? endTime.difference(DateTime.now()).inSeconds > 0
                  ? DateTime.now()
                  : endTime
              : downtime.endTime.difference(endTime).inSeconds > 0
                  ? endTime
                  : downtime.endTime;
          int time = downtimeEndTime.difference(downtimeStartTime).inSeconds;
          switch (type) {
            case "Controlled":
              if (downtime.controlled) {
                totalDowntime += time;
              }
              break;
            case "Planned":
              if (downtime.planned) {
                totalDowntime += time;
              }
              break;
            case "Unplanned":
              if (!downtime.controlled && !downtime.planned) {
                totalDowntime += time;
              }
              break;
            default:
          }
        }
      }
    }
    return totalDowntime;
  }

  Widget selectionWidget() {
    Widget widget = Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "View OEE for Period",
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
                      setState(() {
                        isLoading = true;
                      });
                      map = formFieldWidget.toJSON();
                      map["end_date"] = DateTime.parse(map["end_date"]).add(const Duration(days: 1)).toString().substring(0, 10);
                      startTime = DateTime.parse(map["start_date"]).toUtc();
                      endTime = DateTime.parse(map["end_date"]).toUtc();
                      if (endTime.difference(DateTime.now()).inSeconds > 0) {
                        endTime = DateTime.parse(DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10)).toUtc();
                      }
                      setState(() {
                        isLoading = false;
                      });
                      getBackendData();
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
                        builder: (BuildContext context) => const OEE(),
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

  Widget viewWidget() {
    Widget wid = Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
          child: Text(
            "Period Start:   " + startTime.toLocal().toString().substring(0, 10),
            style: TextStyle(
              color: isDarkTheme.value ? Colors.green : Colors.black,
              fontSize: 24.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
          child: Text(
            "Period End:    " + endTime.subtract(const Duration(days: 1)).toLocal().toString().substring(0, 10),
            style: TextStyle(
              color: isDarkTheme.value ? Colors.green : Colors.black,
              fontSize: 24.0,
            ),
          ),
        ),
        OEEList(lineOEEs: lineOEEs),
      ],
    );
    return wid;
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
                childWidget: isDataLoaded ? viewWidget() : selectionWidget(),
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

class LineOEE {
  final String lineName;
  final double availability;
  final double performance;
  final double quality;
  final double oee;

  LineOEE({
    required this.availability,
    required this.lineName,
    required this.oee,
    required this.performance,
    required this.quality,
  });
}
