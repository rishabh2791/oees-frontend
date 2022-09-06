import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/device.dart';
import 'package:oees/domain/entity/device_data.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/shift.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/domain/entity/task_batch.dart';
import 'package:oees/domain/entity/user_role_access.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/web_socket.dart';
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
  Map<String, String> lineIP = {};
  Map<String, double> skuSpeeds = {};
  Map<String, List<Task>> tasksByLine = {};
  Map<String, List<SKU>> skusByLine = {};
  Map<String, List<Downtime>> downtimeByLine = {};
  Map<int, Map<String, String>> shiftHours = {};
  Map<String, List<Device>> devicesByLine = {};
  late TextEditingController selectedLine;
  Map<String, List<DeviceData>> deviceDataByLine = {};
  Map<String, TaskBatch> runningTaskBatchByLine = {};
  Map<String, List<DeviceData>> otherDeviceDataByLine = {};
  Map<String, double> lineAvailability = {}, linePerformance = {}, lineQuality = {}, lineOEE = {};
  Map<String, double> theoreticalProduction = {}, actualProduction = {}, controlledDowntimes = {}, plannedDowntimes = {}, unplannedDowntimes = {};
  Map<String, List<ControlledDowntime>> controlledDowntimeSeries = {};
  Map<String, List<PlannedDowntime>> plannedDowntimeSeries = {};
  Map<String, List<UnplannedDowntime>> unplannedDowntimeSeries = {};
  Map<String, List<GoodRateProduction>> goodRateSeries = {};
  Map<String, List<BadRateProduction>> badRateSeries = {};
  Map<String, DateTime> lineRunningTaskStartTime = {};
  DateTime shiftStartTime = DateTime.now(), shiftEndTime = DateTime.now(), oldShiftStartTime = DateTime.now();
  late DropdownFormField lineSelectionFormField;
  double runningTaskCount = 0;
  List<double> weights = [];
  Map<String, List<double>> weightsByLineID = {};
  int unitsWeighed = 0;

  @override
  void initState() {
    getUserAuthorizations();
    selectedLine = TextEditingController();
    getBackendData();
    timer = Timer.periodic(const Duration(seconds: 120), (timer) {
      getBackendData();
    });
    if (storage!.getString("line_id") != "") {
      selectedLine.text = storage!.getString("line_id") ?? "";
    }
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    socketUtility.close();
    super.dispose();
  }

  void listenToWeighingScale(String data) {
    Map<String, dynamic> scannerData =
        jsonDecode(data.replaceAll(";", ":").replaceAll("[", "{").replaceAll("]", "}").replaceAll("'", "\"").replaceAll("-", "_"));
    try {
      if (scannerData.containsKey("error")) {
      } else {
        double currentWeight = double.parse((scannerData["data"]).toString());
        var tempList = weightsByLineID[selectedLine.text]!;
        weightsByLineID[selectedLine.text] = [];
        weightsByLineID[selectedLine.text]!.add(currentWeight);
        if (tempList.isNotEmpty) {
          int last = min(4, tempList.length);
          for (int i = 0; i < last; i++) {
            weightsByLineID[selectedLine.text]!.add(tempList[i]);
          }
        }
        unitsWeighed += 1;
        setState(() {});
      }
    } catch (e) {
      FLog.info(text: "Unable to Connect to Scale");
    }
  }

  Future<void> getUserAuthorizations() async {
    userRolePermissions = [];
    await appStore.userRoleAccessApp.list(currentUser.userRole.id).then((response) {
      if (response.containsKey("error")) {
      } else {
        if (response["status"]) {
          for (var item in response["payload"]) {
            UserRoleAccess userRoleAccess = UserRoleAccess.fromJSON(item);
            userRolePermissions.add(userRoleAccess);
          }
        }
      }
    });
  }

  Future<void> getBackendData() async {
    socketUtility.close();
    await Future.wait([
      getShifts(),
      getLines(),
    ]).then(
      (value) async {
        if (lines.isNotEmpty) {
          lineSelectionFormField = DropdownFormField(
            formField: "line_id",
            controller: selectedLine,
            dropdownItems: lines,
            hint: "Select Line",
          );
          if (storage!.getString("line_id") != "") {
            selectedLine.text = storage!.getString("line_id") ?? lines[0].id;
          } else {
            selectedLine.text = lines[0].id;
          }
          selectedLine.addListener(() async {
            if (selectedLine.text.isNotEmpty && runningTaskBatchByLine.containsKey(selectedLine.text)) {
              await Future.forEach([socketUtility.close()], (element) => null).then((value) async {
                await Future.forEach([await socketUtility.initCommunication(lineIP[selectedLine.text] ?? webSocketURL)], (element) => null)
                    .then((value) async {
                  socketUtility.addListener(listenToWeighingScale);
                });
              });
              await Future.wait([
                getRunningBatchUnits(runningTaskBatchByLine[selectedLine.text]!),
                getUnitsWeighed(runningTaskBatchByLine[selectedLine.text]!),
              ]).then((value) {
                setState(() {
                  isLoading = false;
                  isDataLoaded = true;
                });
              });
            } else {
              setState(() {});
            }
          });
          await Future.forEach([await socketUtility.initCommunication(lineIP[selectedLine.text] ?? webSocketURL)], (element) => null)
              .then((value) async {
            socketUtility.addListener(listenToWeighingScale);
          });
          if (lines.isEmpty || shifts.isEmpty) {
            setState(() {
              isLoading = false;
            });
          } else {
            await Future.forEach([
              await getHours(),
            ], (element) {})
                .then((value) async {
              await Future.wait([
                getDowntimes(),
                getTasks(),
              ]);
            }).then(
              (value) async {
                if (skuIDs.isEmpty) {
                  setState(() {
                    isLoading = false;
                  });
                } else {
                  await Future.wait([
                    getRunningTaskBatches(),
                    getDevices(),
                  ]).then(
                    (value) async {
                      if (skuSpeeds.isEmpty || deviceIDs.isEmpty) {
                        setState(() {
                          isLoading = false;
                        });
                      } else {
                        if (runningTaskBatchByLine.containsKey(selectedLine.text)) {
                          await Future.wait([
                            getDeviceData(),
                            getRunningBatchUnits(runningTaskBatchByLine[selectedLine.text]!),
                          ]).then((value) async {
                            getRunEfficiency();
                          }).then((value) async {
                            await Future.forEach([
                              getOtherDeviceData(),
                              getChartsData(),
                              await getUnitsWeighed(runningTaskBatchByLine[selectedLine.text]!),
                            ], (element) => null).then((value) {
                              setState(() {
                                isDataLoaded = true;
                                isLoading = false;
                              });
                            });
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
                            socketUtility.initCommunication(lineIP[selectedLine.text] ?? webSocketURL);
                            socketUtility.addListener(listenToWeighingScale);
                            getChartsData();
                            setState(() {
                              isDataLoaded = true;
                              isLoading = false;
                            });
                          });
                        }
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
            shiftStart =
                DateTime(now.year, now.month, now.day, int.parse(startTime.split(":")[0].toString()), int.parse(startTime.split(":")[1].toString()));
            shiftEnd =
                DateTime(now.year, now.month, now.day, int.parse(endTime.split(":")[0].toString()), int.parse(endTime.split(":")[1].toString()));
          } else {
            if (hour < 12) {
              shiftStart = DateTime(yesterday.year, yesterday.month, yesterday.day, int.parse(startTime.split(":")[0].toString()),
                  int.parse(startTime.split(":")[1].toString()));
              shiftEnd =
                  DateTime(now.year, now.month, now.day, int.parse(endTime.split(":")[0].toString()), int.parse(endTime.split(":")[1].toString()));
            } else {
              shiftStart = DateTime(
                  now.year, now.month, now.day, int.parse(startTime.split(":")[0].toString()), int.parse(startTime.split(":")[1].toString()));
              shiftEnd = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, int.parse(endTime.split(":")[0].toString()),
                  int.parse(endTime.split(":")[1].toString()));
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
          if (!lineIP.containsKey(line.id)) {
            if (line.ipAddress != "" || line.ipAddress.isNotEmpty) {
              lineIP[line.id] = "ws://" + line.ipAddress + ":8001/";
            } else {
              lineIP[line.id] = webSocketURL;
            }
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
            downtimeByLine = {};
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
        tasksByLine = {};
        skusByLine = {};
        skuSpeeds = {};
        for (var item in response["payload"]) {
          Task task = Task.fromJSON(item);
          if (!skuSpeeds.containsKey(task.line.id + "_" + task.job.sku.id)) {
            skuSpeeds[task.line.id + "_" + task.job.sku.id] =
                double.parse(task.line.speedType == 1 ? task.job.sku.lowRunSpeed.toString() : task.job.sku.highRunSpeed.toString());
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

  Future<void> getRunningTaskBatches() async {
    for (var key in tasksByLine.entries) {
      bool runningTasks =
          tasksByLine[key.key]!.any((task) => task.endTime.toLocal().difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds == 0);
      if (runningTasks) {
        var lineRunningTask = tasksByLine[key.key]!
            .firstWhere((task) => task.endTime.toLocal().difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds == 0);
        lineRunningTaskStartTime[lineRunningTask.line.id] = lineRunningTask.startTime;
        await appStore.taskBatchApp.list(lineRunningTask.id).then((response) {
          if (response.containsKey("status") && response["status"]) {
            for (var item in response["payload"]) {
              TaskBatch taskBatch = TaskBatch.fromJSON(item);
              if (!taskBatch.complete) {
                runningTaskBatchByLine[lineRunningTask.line.id] = taskBatch;
              }
            }
          }
        });
      }
    }
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
        deviceDataByLine = {};
        otherDeviceDataByLine = {};
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
      double lineTotalTime = 0, lineTotalControlledDowntime = 0, lineTotalPlannedDowntime = 0, lineTotalUnplannedDowntime = 0;
      double lineTheoreticalProduction = 0, lineActualProduction = 0;
      shiftHours.forEach((key, value) {
        if (DateTime.now().difference(DateTime.parse(value["start_time"]!)).inSeconds > 0) {
          if (!hours.contains(key)) {
            hours.add(key);
          }
          double linePeriodControlledDowntime =
              getTotalDowntime(DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID, "Controlled").toDouble();
          double linePeriodPlannedDowntime =
              getTotalDowntime(DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID, "Planned").toDouble();
          double linePeriodUnplannedDowntime =
              getTotalDowntime(DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID, "Unplanned").toDouble();
          double linePeriodProduction =
              getTheoreticalTotalProduction(DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID);
          double actualPeriodProduction =
              getActualTotalDeviceData(DateTime.parse(value["start_time"]!), DateTime.parse(value["end_time"]!), lineID, true);
          actualProduction[key.toString() + "_" + lineID] = actualPeriodProduction;
          theoreticalProduction[key.toString() + "_" + lineID] = linePeriodProduction;
          controlledDowntimes[key.toString() + "_" + lineID] = linePeriodControlledDowntime;
          plannedDowntimes[key.toString() + "_" + lineID] = linePeriodPlannedDowntime;
          unplannedDowntimes[key.toString() + "_" + lineID] = linePeriodUnplannedDowntime;
          lineTheoreticalProduction += linePeriodProduction;
          lineActualProduction += actualPeriodProduction;
          lineTotalTime = lineTotalTime +
              (DateTime.parse(value["end_time"]!).difference(DateTime.now()).inSeconds > 0
                  ? DateTime.now().difference(DateTime.parse(value["start_time"]!)).inSeconds
                  : 3600);
          lineTotalControlledDowntime += linePeriodControlledDowntime;
          lineTotalPlannedDowntime += linePeriodPlannedDowntime;
          lineTotalUnplannedDowntime += linePeriodUnplannedDowntime;
        }
      });
      lineAvailability[lineID] = (lineTotalTime - lineTotalControlledDowntime - lineTotalPlannedDowntime - lineTotalUnplannedDowntime) /
          (lineTotalTime - lineTotalControlledDowntime);
      linePerformance[lineID] = min(1, lineTheoreticalProduction == 0 ? 0 : (lineActualProduction / lineTheoreticalProduction));
      lineQuality[lineID] = 1;
      lineOEE[lineID] = lineTheoreticalProduction == 0 ? 0 : lineAvailability[lineID]! * linePerformance[lineID]! * 1;
    }
  }

  double getTheoreticalTotalProduction(DateTime startTime, DateTime endTime, String lineID) {
    double production = 0;
    if (tasksByLine.containsKey(lineID)) {
      for (var task in tasksByLine[lineID]!) {
        int totalPeriodTime = 3600;
        if (endTime.difference(DateTime.now()).inSeconds > 0) {
          totalPeriodTime = totalPeriodTime - (endTime.difference(DateTime.now()).inSeconds);
        }
        if (!(task.endTime.difference(startTime).inSeconds < 0) || !(task.startTime.difference(endTime).inSeconds > 0)) {
          int totalControlledDowntime = getTotalDowntime(startTime, endTime, lineID, "Controlled");
          int totalPlannedDowntime = getTotalDowntime(startTime, endTime, lineID, "Planned");
          int totalUnplannedDowntime = getTotalDowntime(startTime, endTime, lineID, "Unplanned");
          int totalProductionTime = totalPeriodTime - totalControlledDowntime - totalPlannedDowntime - totalUnplannedDowntime;
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
        if (deviceData.createdAt.difference(startTime).inSeconds > 0 && deviceData.createdAt.difference(endTime).inSeconds < 0) {
          if (forOEE && deviceData.device.useForOEE) {
            production += deviceData.value;
          } else {
            if (otherDeviceDataByLine.containsKey(lineID + "_" + deviceData.device.id)) {
              otherDeviceDataByLine[lineID + "_" + deviceData.device.id]!.add(deviceData);
            } else {
              otherDeviceDataByLine[lineID + "_" + deviceData.device.id] = [deviceData];
            }
          }
        }
      }
    }
    return production;
  }

  Widget getOtherDeviceData() {
    List<Widget> thisWidgets = [];
    var lineID = selectedLine.text;
    otherDeviceDataByLine.forEach((key, value) {
      value.sort(((a, b) => b.createdAt.compareTo(a.createdAt)));
      int last = min(5, value.length);
      if (deviceDataByLine.containsKey(lineID)) {
        var exists = devicesByLine[lineID]!.any((element) => element.id == key.split("_")[1]);
        if (exists) {
          Device device = devicesByLine[lineID]!.firstWhere((element) => element.id == key.split("_")[1]);
          if (device.deviceType.toUpperCase() == "WEIGHING SCALE") {
            if (!weightsByLineID.containsKey(lineID)) {
              weightsByLineID[lineID] = [];
              for (int i = 0; i < last; i++) {
                weightsByLineID[lineID]!.add(value[i].value);
              }
            }
            thisWidgets.add(
              const Text(
                "Weights",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                ),
              ),
            );
            last = min(5, weightsByLineID[lineID]!.length);
            for (int i = 0; i < last; i++) {
              thisWidgets.add(Text(
                weightsByLineID[selectedLine.text]![i].toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 30.0,
                  color: weightsByLineID[selectedLine.text]![i] < getRunningTaks(selectedLine.text).minWeight ? Colors.red : Colors.green,
                ),
              ));
            }
          } else {
            if (key.split("_")[0] == lineID) {
              thisWidgets.add(
                Text(
                  devicesByLine[lineID]!.firstWhere((element) => element.id == key.split("_")[1]).description,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30.0,
                  ),
                ),
              );
              value.sort(((a, b) => b.createdAt.compareTo(a.createdAt)));
              for (int i = 0; i < last; i++) {
                thisWidgets.add(Text(
                  value[i].value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 30.0,
                    color: value[i].value < getRunningTaks(selectedLine.text).minWeight ? Colors.red : Colors.green,
                  ),
                ));
              }
            }
          }
        }
      }
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: thisWidgets,
    );
  }

  Future<void> getUnitsWeighed(TaskBatch runningTaskBatch) async {
    // unitsWeighed = 0;
    // var lineID = selectedLine.text;
    // otherDeviceDataByLine.forEach((key, value) {
    //   if (key.split("_")[0] == lineID) {
    //     if (deviceDataByLine.containsKey(lineID)) {
    //       var exists = devicesByLine[lineID]!.any((element) => element.id == key.split("_")[1]);
    //       if (exists) {
    //         Device device = devicesByLine[lineID]!.firstWhere((element) => element.id == key.split("_")[1]);
    //         if (device.deviceType.toUpperCase() == "WEIGHING SCALE") {
    //           unitsWeighed = value.length;
    //         }
    //       }
    //     }
    //   }
    // });
    var lineID = selectedLine.text;
    Map<String, dynamic> deviceCondition = {
      "AND": [
        {
          "EQUALS": {
            "Field": "line_id",
            "Value": lineID,
          }
        },
        {
          "EQUALS": {
            "Field": "use_for_oee",
            "Value": "0",
          }
        },
      ],
    };
    await appStore.deviceApp.list(deviceCondition).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        Device device = Device.fromJSON(response["payload"][0]);
        Map<String, dynamic> deviceDataCondition = {
          "AND": [
            {
              "EQUALS": {
                "Field": "device_id",
                "Value": device.id,
              },
            },
            {
              "GREATEREQUAL": {
                "Field": "created_at",
                "Value": runningTaskBatch.startTime.toUtc().toString().substring(0, 10) +
                    "T" +
                    runningTaskBatch.startTime.toUtc().toString().substring(11, 19) +
                    "Z",
              },
            },
          ],
        };
        await appStore.deviceDataApp.list(deviceDataCondition).then((value) {
          if (value.containsKey("status") && value["status"] && device.deviceType.toUpperCase() == "WEIGHING SCALE") {
            unitsWeighed = value["payload"].length;
          }
        });
      }
    });
    setState(() {});
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

  dynamic getRunningTaks(String lineID) {
    String sku = "";
    List<Task> lineTasks = tasksByLine[lineID] ?? [];
    if (lineTasks.isNotEmpty) {
      for (var task in lineTasks) {
        if (task.endTime.toLocal().difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds == 0) {
          return task.job.sku;
        }
      }
    }
    return sku;
  }

  Future<void> getRunningBatchUnits(TaskBatch runningTaskBatch) async {
    var lineID = runningTaskBatch.task.line.id;
    Map<String, dynamic> deviceCondition = {
      "AND": [
        {
          "EQUALS": {
            "Field": "line_id",
            "Value": lineID,
          }
        },
        {
          "EQUALS": {
            "Field": "use_for_oee",
            "Value": "1",
          }
        },
      ],
    };
    await appStore.deviceApp.list(deviceCondition).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        double counts = 0;
        Device device = Device.fromJSON(response["payload"][0]);
        Map<String, dynamic> deviceDataCondition = {
          "AND": [
            {
              "EQUALS": {
                "Field": "device_id",
                "Value": device.id,
              },
            },
            {
              "GREATEREQUAL": {
                "Field": "created_at",
                "Value": runningTaskBatch.startTime.toUtc().toString().substring(0, 10) +
                    "T" +
                    runningTaskBatch.startTime.toUtc().toString().substring(11, 19) +
                    "Z",
              },
            },
          ],
        };
        await appStore.deviceDataApp.totalDeviceData(deviceDataCondition).then((value) {
          if (value.containsKey("status") && value["status"]) {
            counts += value["payload"]["value"];
          }
          setState(() {
            runningTaskCount = counts;
          });
          setState(() {
            isLoading = false;
          });
        });
      }
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
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: (MediaQuery.of(context).size.width - 500) / 2,
                                        child: Text(
                                          getRunningTaks(selectedLine.text).runtimeType == String
                                              ? "SKU: "
                                              : "SKU: " +
                                                  getRunningTaks(selectedLine.text).code +
                                                  " - " +
                                                  getRunningTaks(selectedLine.text).description,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lineAvailability.containsKey(selectedLine.text)
                                            ? "Availability: " + lineAvailability[selectedLine.text]!.toStringAsFixed(2)
                                            : "Availability: 0",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      Text(
                                        linePerformance.containsKey(selectedLine.text)
                                            ? "Performance: " + linePerformance[selectedLine.text]!.toStringAsFixed(2)
                                            : "Performance: 0",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      Text(
                                        lineQuality.containsKey(selectedLine.text)
                                            ? "Quality: " + lineQuality[selectedLine.text]!.toStringAsFixed(2)
                                            : "Quality: 0",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      Text(
                                        lineOEE.containsKey(selectedLine.text) ? "OEE: " + lineOEE[selectedLine.text]!.toStringAsFixed(2) : "OEE: 0",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  runningTaskBatchByLine.containsKey(selectedLine.text)
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Running Batch: " + runningTaskBatchByLine[selectedLine.text]!.batchNumber,
                                              style: TextStyle(
                                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            Text(
                                              "Batch Size: " +
                                                  runningTaskBatchByLine[selectedLine.text]!
                                                      .batchSize
                                                      .toStringAsFixed(1)
                                                      .replaceAllMapped(reg, (Match match) => '${match[1]},') +
                                                  " KG",
                                              style: TextStyle(
                                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            getRunningTaks(selectedLine.text).runtimeType == String
                                                ? Container()
                                                : Text(
                                                    "Minimum Weight: " + getRunningTaks(selectedLine.text).minWeight.toStringAsFixed(0),
                                                    style: TextStyle(
                                                      color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                            getRunningTaks(selectedLine.text).runtimeType == String
                                                ? Container()
                                                : Text(
                                                    "Expected Weight: " + getRunningTaks(selectedLine.text).expectedWeight.toStringAsFixed(0),
                                                    style: TextStyle(
                                                      color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                          ],
                                        )
                                      : Container(),
                                  runningTaskBatchByLine.containsKey(selectedLine.text)
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Expected Batch Units: " +
                                                  (runningTaskBatchByLine[selectedLine.text]!.batchSize *
                                                          1000 /
                                                          (getRunningTaks(selectedLine.text).runtimeType.toString() == "String"
                                                              ? 1
                                                              : getRunningTaks(selectedLine.text).expectedWeight))
                                                      .toStringAsFixed(0)
                                                      .replaceAllMapped(reg, (Match match) => '${match[1]},'),
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            Text(
                                              "Actual Batch Units: " +
                                                  (runningTaskCount.toStringAsFixed(0).replaceAllMapped(reg, (Match match) => '${match[1]},')),
                                              style: TextStyle(
                                                color: (runningTaskCount <=
                                                        runningTaskBatchByLine[selectedLine.text]!.batchSize *
                                                            1000 /
                                                            (getRunningTaks(selectedLine.text).runtimeType.toString() == "String"
                                                                ? 1
                                                                : getRunningTaks(selectedLine.text).expectedWeight))
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            Text(
                                              "Batch Units Weighed: " + (unitsWeighed.toStringAsFixed(0)),
                                              style: TextStyle(
                                                color: (unitsWeighed < 50) ? Colors.red : Colors.green,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
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
                          // width: MediaQuery.of(context).size.width / 2,
                          child: charts.BarChart(
                            buildChart(),
                            animate: true,
                            defaultRenderer: charts.BarRendererConfig(
                              groupingType: charts.BarGroupingType.stacked,
                              strokeWidthPx: 2.0,
                              cornerStrategy: const charts.ConstCornerStrategy(10),
                              maxBarWidthPx: 60,
                            ),
                            behaviors: [
                              charts.SeriesLegend(
                                position: charts.BehaviorPosition.start,
                                entryTextStyle: charts.TextStyleSpec(
                                  color: charts.MaterialPalette.purple.shadeDefault,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        getOtherDeviceData(),
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
                        " ",
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
