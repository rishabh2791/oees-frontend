import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/device.dart';
import 'package:oees/domain/entity/device_data.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/shift.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/domain/entity/sku_speed.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/hourly_series/bad.dart';
import 'package:oees/interface/common/hourly_series/controlled.dart';
import 'package:oees/interface/common/hourly_series/good.dart';
import 'package:oees/interface/common/hourly_series/planned.dart';
import 'package:oees/interface/common/hourly_series/unplanned.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GeneralHomeWidget extends StatefulWidget {
  const GeneralHomeWidget({Key? key}) : super(key: key);

  @override
  State<GeneralHomeWidget> createState() => _GeneralHomeWidgetState();
}

class _GeneralHomeWidgetState extends State<GeneralHomeWidget> {
  late Timer timer;
  bool isLoading = true;
  bool isDataLoaded = false;
  List<int> hours = [];
  List<Shift> shifts = [];
  List<Line> lines = [];
  List<String> lineIDs = [];
  List<String> skuIDs = [];
  List<String> deviceIDs = [];
  Map<String, double> skuSpeeds = {};
  Map<String, List<Task>> tasksByLine = {};
  Map<String, List<SKU>> skusByLine = {};
  Map<String, List<Downtime>> downtimeByLine = {};
  Map<int, Map<String, String>> shiftHours = {};
  Map<String, List<Device>> devicesByLine = {};
  late TextEditingController selectedLine;
  Map<String, List<DeviceData>> deviceDataByLine = {};
  Map<String, double> lineAvailability = {}, linePerformance = {}, lineQuality = {}, lineOEE = {};
  Map<String, double> theoreticalProduction = {},
      actualProduction = {},
      controlledDowntimes = {},
      plannedDowntimes = {},
      unplannedDowntimes = {};
  Map<String, List<ControlledDowntime>> controlledDowntimeSeries = {};
  Map<String, List<PlannedDowntime>> plannedDowntimeSeries = {};
  Map<String, List<UnplannedDowntime>> unplannedDowntimeSeries = {};
  Map<String, List<GoodRateProduction>> goodRateSeries = {};
  Map<String, List<BadRateProduction>> badRateSeries = {};
  DateTime shiftStartTime = DateTime.now(), shiftEndTime = DateTime.now(), oldShiftStartTime = DateTime.now();
  late DropdownFormField lineSelectionFormField;

  @override
  void initState() {
    selectedLine = TextEditingController();
    getBackendData();
    timer = Timer.periodic(const Duration(seconds: 120), (timer) {
      getBackendData();
    });
    if (storage!.getString("line_id") != "") {
      selectedLine.text = storage!.getString("line_id") ?? "";
    }
    selectedLine.addListener(() {
      if (selectedLine.text.isNotEmpty) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> getBackendData() async {
    setState(() {
      isLoading = true;
      isDataLoaded = false;
    });
    await Future.forEach([
      await getShifts(),
      await getLines(),
    ], (element) {})
        .then(
      (value) async {
        if (lines.isNotEmpty) {
          lineSelectionFormField = DropdownFormField(
            formField: "line_id",
            controller: selectedLine,
            dropdownItems: lines,
            hint: "Select Line",
          );
          selectedLine.text = lines[0].id;
          if (lines.isEmpty || shifts.isEmpty) {
            setState(() {
              isLoading = false;
            });
          } else {
            await Future.forEach([
              await getHours(),
            ], (element) {})
                .then((value) async {
              await Future.forEach([
                await getDowntimes(),
                await getTasks(),
              ], (element) async {});
            }).then(
              (value) async {
                if (skuIDs.isEmpty) {
                  setState(() {
                    isLoading = false;
                  });
                } else {
                  await Future.forEach([
                    await getRunSpeeds(),
                    await getDevices(),
                  ], (element) async {})
                      .then(
                    (value) async {
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
                        }).then((value) {
                          getChartsData();
                          setState(() {
                            isDataLoaded = true;
                            isLoading = false;
                          });
                        });
                      }
                    },
                  );
                }
              },
            );
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      },
    );
  }

  Future<void> getShifts() async {
    shifts = [];
    await appStore.shiftApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Shift shift = Shift.fromJSON(item);
          shifts.add(shift);
          late DateTime shiftStart, shiftEnd;
          String startTime = shift.startTime;
          String endTime = shift.endTime;
          DateTime now = DateTime.now();
          int hour = now.hour;
          DateTime tomorrow = now.add(const Duration(days: 1));
          DateTime yesterday = now.subtract(const Duration(days: 1));
          int shiftStartHour = int.parse(shift.startTime.split(":")[0].toString());
          int shiftEndHour = int.parse(shift.endTime.split(":")[0].toString());

          if (shiftEndHour > shiftStartHour) {
            shiftStart = DateTime(now.year, now.month, now.day, int.parse(startTime.split(":")[0].toString()),
                int.parse(startTime.split(":")[1].toString()));
            shiftEnd = DateTime(now.year, now.month, now.day, int.parse(endTime.split(":")[0].toString()),
                int.parse(endTime.split(":")[1].toString()));
          } else {
            if (hour < 12) {
              shiftStart = DateTime(yesterday.year, yesterday.month, yesterday.day,
                  int.parse(startTime.split(":")[0].toString()), int.parse(startTime.split(":")[1].toString()));
              shiftEnd = DateTime(now.year, now.month, now.day, int.parse(endTime.split(":")[0].toString()),
                  int.parse(endTime.split(":")[1].toString()));
            } else {
              shiftStart = DateTime(now.year, now.month, now.day, int.parse(startTime.split(":")[0].toString()),
                  int.parse(startTime.split(":")[1].toString()));
              shiftEnd = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
                  int.parse(endTime.split(":")[0].toString()), int.parse(endTime.split(":")[1].toString()));
            }
          }

          if (now.difference(shiftStart).inMinutes * now.difference(shiftEnd).inMinutes < 0) {
            shiftStartTime = shiftStart;
            shiftEndTime = shiftEnd;
          }

          if (oldShiftStartTime != shiftStartTime) {
            setState(() {
              oldShiftStartTime = shiftStartTime;
            });
          }
        }
      }
    });
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
        }
      }
    });
    if (lines.isNotEmpty) {
      selectedLine.text = lines[0].id;
    }
  }

  Future<void> getHours() async {
    shiftHours = {};
    DateTime hourStart = shiftStartTime;
    DateTime hourEnd = shiftStartTime.add(const Duration(hours: 1));
    int hour = 1;
    while (hourStart.difference(shiftEndTime).inSeconds < 0) {
      shiftHours[hour] = {
        "start_time": hourStart.toLocal().toString(),
        "end_time": hourEnd.toLocal().toString(),
      };
      hourStart = hourEnd;
      hourEnd = hourEnd.add(const Duration(hours: 1));
      hour++;
    }
  }

  Future<void> getDowntimes() async {
    downtimeByLine = {};
    await Future.forEach([lines], (element) async {
      for (var line in lines) {
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
                    "LowerValue": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                    "HigherValue": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                  }
                },
                {
                  "BETWEEN": {
                    "Field": "end_time",
                    "LowerValue": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                    "HigherValue": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
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
      }
    });
  }

  Future<void> getTasks() async {
    tasksByLine = {};
    skusByLine = {};

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
                "LowerValue": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                "HigherValue": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
              }
            },
            {
              "BETWEEN": {
                "Field": "end_time",
                "LowerValue": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
                "HigherValue": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
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
        for (var item in response["payload"]) {
          Task task = Task.fromJSON(item);
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

  Future<void> getRunSpeeds() async {
    skuSpeeds = {};
    Map<String, dynamic> conditions = {
      "AND": [
        {
          "IN": {
            "Field": "line_id",
            "Value": lineIDs,
          }
        },
        {
          "IN": {
            "Field": "sku_id",
            "Value": skuIDs,
          }
        },
      ],
    };
    await appStore.skuSpeedApp.list(conditions).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          SKUSpeed skuSpeed = SKUSpeed.fromJSON(item);
          skuSpeeds[skuSpeed.line.id + "_" + skuSpeed.sku.id] = skuSpeed.speed;
        }
      }
    });
  }

  Future<void> getDevices() async {
    devicesByLine = {};
    Map<String, dynamic> conditions = {
      "IN": {
        "Field": "line_id",
        "Value": lineIDs,
      }
    };
    await appStore.deviceApp.list(conditions).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Device device = Device.fromJSON(item);
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
    });
  }

  Future<void> getDeviceData() async {
    deviceDataByLine = {};
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
            "LowerValue": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
            "HigherValue": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
          }
        },
      ]
    };
    await appStore.deviceDataApp.list(conditions).then((response) {
      if (response.containsKey("status") && response["status"]) {
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
    for (var lineID in lineIDs) {
      double lineTotalTime = 0,
          lineTotalControlledDowntime = 0,
          lineTotalPlannedDowntime = 0,
          lineTotalUnplannedDowntime = 0;
      double lineTheoreticalProduction = 0, lineActualProduction = 0;
      shiftHours.forEach((key, value) {
        if (DateTime.now().difference(DateTime.parse(value["start_time"]!)).inSeconds > 0) {
          if (!hours.contains(key)) {
            hours.add(key);
          }
          double linePeriodControlledDowntime = getTotalDowntime(
                  DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID, "Controlled")
              .toDouble();
          double linePeriodPlannedDowntime = getTotalDowntime(
                  DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID, "Planned")
              .toDouble();
          double linePeriodUnplannedDowntime = getTotalDowntime(
                  DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID, "Unplanned")
              .toDouble();
          double linePeriodProduction = getTheoreticalTotalProduction(
              DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID);
          double actualPeriodProduction = getActualTotalDeviceData(
              DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID, true);
          actualProduction[key.toString() + "_" + lineID] = actualPeriodProduction;
          theoreticalProduction[key.toString() + "_" + lineID] = linePeriodProduction;
          controlledDowntimes[key.toString() + "_" + lineID] = linePeriodControlledDowntime;
          plannedDowntimes[key.toString() + "_" + lineID] = linePeriodPlannedDowntime;
          unplannedDowntimes[key.toString() + "_" + lineID] = linePeriodUnplannedDowntime;
          lineTheoreticalProduction += linePeriodProduction;
          lineActualProduction += actualPeriodProduction;
          lineTotalTime += 3600;
          lineTotalControlledDowntime += linePeriodControlledDowntime;
          lineTotalPlannedDowntime += linePeriodPlannedDowntime;
          lineTotalUnplannedDowntime += linePeriodUnplannedDowntime;
        }
      });
      lineAvailability[lineID] =
          (lineTotalTime - lineTotalControlledDowntime - lineTotalPlannedDowntime - lineTotalUnplannedDowntime) /
              (lineTotalTime - lineTotalControlledDowntime);
      linePerformance[lineID] = lineTheoreticalProduction == 0 ? 0 : (lineActualProduction / lineTheoreticalProduction);
      lineQuality[lineID] = 1;
      lineOEE[lineID] = lineTheoreticalProduction == 0
          ? 0
          : ((lineTotalTime - lineTotalControlledDowntime - lineTotalPlannedDowntime - lineTotalUnplannedDowntime) /
                  (lineTotalTime - lineTotalControlledDowntime)) *
              (lineActualProduction / lineTheoreticalProduction) *
              1;
    }
  }

  double getTheoreticalTotalProduction(DateTime startTime, DateTime endTime, String lineID) {
    double production = 0;
    if (tasksByLine.containsKey(lineID)) {
      for (var task in tasksByLine[lineID]!) {
        if (!(task.endTime.difference(startTime).inSeconds < 0) ||
            !(task.startTime.difference(endTime).inSeconds > 0)) {
          int totalControlledDowntime = getTotalDowntime(startTime, endTime, lineID, "Controlled");
          int totalPlannedDowntime = getTotalDowntime(startTime, endTime, lineID, "Planned");
          int totalUnplannedDowntime = getTotalDowntime(startTime, endTime, lineID, "Unplanned");
          int totalProductionTime = 3600 - totalControlledDowntime - totalPlannedDowntime - totalUnplannedDowntime;
          var speed = skuSpeeds[lineID + "_" + task.job.sku.id] ?? 0;
          production += speed * double.parse(totalProductionTime.toString()) / 60;
        }
      }
    }
    return production;
  }

  double getActualTotalDeviceData(DateTime startTime, DateTime endTime, String lineID, bool forOEE) {
    double production = 0;
    if (deviceDataByLine.containsKey(lineID)) {
      for (var deviceData in deviceDataByLine[lineID]!) {
        if (deviceData.createdAt.difference(startTime).inSeconds > 0 &&
            deviceData.createdAt.difference(endTime).inSeconds < 0) {
          if (forOEE && deviceData.device.useForOEE) {
            production += deviceData.value;
          }
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
        if ((downtime.endTime.difference(startTime).inSeconds < 0) ||
            (downtime.startTime.difference(endTime).inSeconds > 0)) {
          //do nothing
        } else {
          DateTime downtimeStartTime =
              downtime.startTime.difference(startTime).inSeconds < 0 ? startTime : downtime.startTime;
          DateTime downtimeEndTime = downtime.endTime.difference(endTime).inSeconds < 0 ? downtime.endTime : endTime;
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
              totalDowntime += time;
          }
        }
      }
    }
    return totalDowntime;
  }

  void getChartsData() {
    controlledDowntimeSeries = {};
    plannedDowntimeSeries = {};
    unplannedDowntimeSeries = {};
    goodRateSeries = {};
    badRateSeries = {};
    controlledDowntimes.forEach((key, value) {
      int hour = int.parse(key.split("_")[0].toString());
      String lineID = key.split("_")[1];
      if (controlledDowntimeSeries.containsKey(lineID)) {
        controlledDowntimeSeries[lineID]!.add(ControlledDowntime(downtime: value / 60, hour: hour));
      } else {
        controlledDowntimeSeries[lineID] = [ControlledDowntime(downtime: value / 60, hour: hour)];
      }
    });
    plannedDowntimes.forEach((key, value) {
      int hour = int.parse(key.split("_")[0].toString());
      String lineID = key.split("_")[1];
      if (plannedDowntimeSeries.containsKey(lineID)) {
        plannedDowntimeSeries[lineID]!.add(PlannedDowntime(downtime: value / 60, hour: hour));
      } else {
        plannedDowntimeSeries[lineID] = [PlannedDowntime(downtime: value / 60, hour: hour)];
      }
    });
    unplannedDowntimes.forEach((key, value) {
      int hour = int.parse(key.split("_")[0].toString());
      String lineID = key.split("_")[1];
      if (unplannedDowntimeSeries.containsKey(lineID)) {
        unplannedDowntimeSeries[lineID]!.add(UnplannedDowntime(downtime: value / 60, hour: hour));
      } else {
        unplannedDowntimeSeries[lineID] = [UnplannedDowntime(downtime: value / 60, hour: hour)];
      }
    });
    theoreticalProduction.forEach((key, value) {
      int hour = int.parse(key.split("_")[0].toString());
      String lineID = key.split("_")[1];
      double productionTime = 60 - (controlledDowntimes[key]! + plannedDowntimes[key]! + unplannedDowntimes[key]!) / 60;
      double good = 0;
      if (theoreticalProduction[key] != 0) {
        good = min(productionTime * actualProduction[key]! / (theoreticalProduction[key]!), productionTime);
      }
      double bad = productionTime - good;
      if (goodRateSeries.containsKey(lineID)) {
        goodRateSeries[lineID]!.add(GoodRateProduction(hour: hour, production: good));
      } else {
        goodRateSeries[lineID] = [GoodRateProduction(hour: hour, production: good)];
      }
      if (badRateSeries.containsKey(lineID)) {
        badRateSeries[lineID]!.add(BadRateProduction(hour: hour, production: bad));
      } else {
        badRateSeries[lineID] = [BadRateProduction(hour: hour, production: bad)];
      }
    });
  }

  List<charts.Series<dynamic, String>> buildChart() {
    return [
      charts.Series<BadRateProduction, String>(
        id: "Production Loss",
        domainFn: (BadRateProduction downtime, _) => downtime.hour.toString(),
        measureFn: (BadRateProduction downtime, _) => downtime.production,
        data: badRateSeries[selectedLine.text] ?? [],
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        fillColorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
      charts.Series<GoodRateProduction, String>(
        id: "Optimum Production",
        domainFn: (GoodRateProduction downtime, _) => downtime.hour.toString(),
        measureFn: (GoodRateProduction downtime, _) => downtime.production,
        data: goodRateSeries[selectedLine.text] ?? [],
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        fillColorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
      charts.Series<UnplannedDowntime, String>(
        id: "Unplanned Downtime",
        domainFn: (UnplannedDowntime downtime, _) => downtime.hour.toString(),
        measureFn: (UnplannedDowntime downtime, _) => downtime.downtime,
        data: unplannedDowntimeSeries[selectedLine.text] ?? [],
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
      ),
      charts.Series<PlannedDowntime, String>(
        id: "Planned Downtime",
        domainFn: (PlannedDowntime downtime, _) => downtime.hour.toString(),
        measureFn: (PlannedDowntime downtime, _) => downtime.downtime,
        data: plannedDowntimeSeries[selectedLine.text] ?? [],
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        fillColorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
      charts.Series<ControlledDowntime, String>(
        id: "Controlled Downtime",
        domainFn: (ControlledDowntime downtime, _) => downtime.hour.toString(),
        measureFn: (ControlledDowntime downtime, _) => downtime.downtime,
        data: controlledDowntimeSeries[selectedLine.text] ?? [],
        colorFn: (_, __) => charts.MaterialPalette.black,
        fillColorFn: (_, __) => charts.MaterialPalette.black,
      ),
    ];
  }

  String getRunningTaks(String lineID) {
    String sku = "";
    List<Task> lineTasks = tasksByLine[lineID] ?? [];
    if (lineTasks.isNotEmpty) {
      for (var task in lineTasks) {
        if (task.endTime.toLocal().difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds == 0) {
          sku = task.job.sku.code + " - " + task.job.sku.description;
        }
      }
    }
    return sku;
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
                ? Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Color(0xFFFEFBE7),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 500,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Line: " +
                                            lines
                                                .where((element) => element.id == selectedLine.text)
                                                .toString()
                                                .replaceAll("(", "")
                                                .replaceAll(")", ""),
                                        style: TextStyle(
                                          color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                          fontSize: 30.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: (MediaQuery.of(context).size.width - 500) / 2,
                                        child: Text(
                                          getRunningTaks(selectedLine.text) == ""
                                              ? "No Job Running"
                                              : "SKU: " + getRunningTaks(selectedLine.text),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                            fontSize: 30.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Availability: " + lineAvailability[selectedLine.text]!.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                          fontSize: 30.0,
                                        ),
                                      ),
                                      Text(
                                        "Performance: " + linePerformance[selectedLine.text]!.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                          fontSize: 30.0,
                                        ),
                                      ),
                                      Text(
                                        "Quality: " + lineQuality[selectedLine.text]!.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                          fontSize: 30.0,
                                        ),
                                      ),
                                      Text(
                                        "OEE: " + lineOEE[selectedLine.text]!.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                          fontSize: 30.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 400,
                              child: lineSelectionFormField.render(),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 250,
                          child: charts.BarChart(
                            buildChart(),
                            animate: true,
                            defaultRenderer: charts.BarRendererConfig(
                              groupingType: charts.BarGroupingType.stacked,
                              strokeWidthPx: 2.0,
                            ),
                            behaviors: [
                              charts.SeriesLegend(
                                position: charts.BehaviorPosition.start,
                                entryTextStyle: charts.TextStyleSpec(
                                  color: charts.MaterialPalette.purple.shadeDefault,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Color(0xFFFEFBE7),
                    ),
                    child: Center(
                      child: Text(
                        "No Data Found.",
                        style: TextStyle(
                          color: isDarkTheme.value ? backgroundColor : foregroundColor,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  );
      },
    );
  }
}
