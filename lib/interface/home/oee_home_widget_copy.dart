// import 'dart:async';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:oees/application/app_store.dart';
// import 'package:oees/domain/entity/device.dart';
// import 'package:oees/domain/entity/device_data.dart';
// import 'package:oees/domain/entity/downtime.dart';
// import 'package:oees/domain/entity/line.dart';
// import 'package:oees/domain/entity/shift.dart';
// import 'package:oees/domain/entity/task.dart';
// import 'package:oees/infrastructure/constants.dart';
// import 'package:oees/infrastructure/variables.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:oees/interface/common/time_series.dart/availability.dart';
// import 'package:oees/interface/common/time_series.dart/oee.dart';
// import 'package:oees/interface/common/time_series.dart/performance.dart';
// import 'package:oees/interface/common/time_series.dart/quality.dart';

// class OEEHomeWidget extends StatefulWidget {
//   const OEEHomeWidget({Key? key}) : super(key: key);

//   @override
//   State<OEEHomeWidget> createState() => _OEEHomeWidgetState();
// }

// class _OEEHomeWidgetState extends State<OEEHomeWidget> {
//   bool isLoading = true;
//   Map<String, List<TimeSeriesAvailability>> availability = {};
//   Map<String, List<TimeSeriesPerformance>> performance = {};
//   Map<String, List<TimeSeriesQuality>> quality = {};
//   Map<String, List<TimeSeriesOEE>> oee = {};
//   List<Shift> shifts = [];
//   List<Line> lines = [];
//   Map<String, double> productionByLineID = {};
//   Map<String, double> availabilityByLineID = {};
//   Map<String, double> performanceByLineID = {};
//   Map<String, double> qualityByLineID = {};
//   Map<String, double> oeeByLineID = {};
//   Map<String, String> deviceByLineID = {};
//   Map<String, int> totalPlannedDowntimeByLineID = {}, totalUnplannedDowntimeByLineID = {}, totalControlledDowntimeByLineID = {};
//   Map<String, List<Task>> tasksByLineID = {};
//   Map<String, List<Downtime>> plannedDowntimesByLineID = {}, unplannedDowntimesByLineID = {}, controlledDowntimesByLineID = {};
//   Map<String, List<String>> skusByLineID = {};
//   Map<String, double> skuLlineSpeed = {};
//   DateTime shiftStartTime = DateTime.now(), shiftEndTime = DateTime.now(), oldShiftStartTime = DateTime.now();
//   late Timer timer;
//   Map<String, List<charts.Series<dynamic, DateTime>>> availabilitySeriesData = {},
//       performanceSeriesData = {},
//       qualitySeriesData = {},
//       oeeSeriesData = {};

//   @override
//   void initState() {
//     getBackendData();
//     timer = Timer.periodic(const Duration(seconds: 120), (timer) {
//       getBackendData();
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     timer.cancel();
//     super.dispose();
//   }

//   Future<void> getBackendData() async {
//     setState(() {
//       isLoading = true;
//     });
//     DateTime now = DateTime.now();
//     await Future.forEach([await getShifts()], (element) {}).then((value) async {
//       await getData();
//     }).then((value) async {
//       for (var line in lines) {
//         if (availability.containsKey(line.id)) {
//           availability[line.id]!.add(TimeSeriesAvailability(availability: availabilityByLineID[line.id] ?? 0, time: now));
//         } else {
//           availability[line.id] = [TimeSeriesAvailability(availability: availabilityByLineID[line.id] ?? 0, time: now)];
//         }
//         if (performance.containsKey(line.id)) {
//           performance[line.id]!.add(TimeSeriesPerformance(performance: performanceByLineID[line.id] ?? 0, time: now));
//         } else {
//           performance[line.id] = [TimeSeriesPerformance(performance: performanceByLineID[line.id] ?? 0, time: now)];
//         }
//         if (quality.containsKey(line.id)) {
//           quality[line.id]!.add(TimeSeriesQuality(quality: qualityByLineID[line.id] ?? 0, time: now));
//         } else {
//           quality[line.id] = [TimeSeriesQuality(quality: qualityByLineID[line.id] ?? 0, time: now)];
//         }
//         if (oee.containsKey(line.id)) {
//           oee[line.id]!.add(TimeSeriesOEE(oee: oeeByLineID[line.id] ?? 0, time: now));
//         } else {
//           oee[line.id] = [TimeSeriesOEE(oee: oeeByLineID[line.id] ?? 0, time: now)];
//         }
//       }
//     }).then((value) {
//       setState(() {
//         isLoading = false;
//       });
//       for (var line in lines) {
//         if (!availabilitySeriesData.containsKey(line.id)) {
//           availabilitySeriesData[line.id] = [];
//         }
//         if (!performanceSeriesData.containsKey(line.id)) {
//           availabilitySeriesData[line.id] = [];
//         }
//         if (!qualitySeriesData.containsKey(line.id)) {
//           availabilitySeriesData[line.id] = [];
//         }
//         if (!oeeSeriesData.containsKey(line.id)) {
//           availabilitySeriesData[line.id] = [];
//         }
//         oeeSeriesData[line.id] = [
//           charts.Series<TimeSeriesAvailability, DateTime>(
//             id: 'Availability',
//             colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//             domainFn: (TimeSeriesAvailability sales, _) => sales.time,
//             measureFn: (TimeSeriesAvailability sales, _) => sales.availability,
//             data: availability[line.id] ?? [],
//           ),
//           charts.Series<TimeSeriesPerformance, DateTime>(
//             id: 'Performance',
//             colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
//             domainFn: (TimeSeriesPerformance sales, _) => sales.time,
//             measureFn: (TimeSeriesPerformance sales, _) => sales.performance,
//             data: performance[line.id] ?? [],
//           ),
//           charts.Series<TimeSeriesQuality, DateTime>(
//             id: 'Quality',
//             colorFn: (_, __) => charts.MaterialPalette.black,
//             domainFn: (TimeSeriesQuality sales, _) => sales.time,
//             measureFn: (TimeSeriesQuality sales, _) => sales.quality,
//             data: quality[line.id] ?? [],
//           ),
//           charts.Series<TimeSeriesOEE, DateTime>(
//             id: 'OEE',
//             colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
//             domainFn: (TimeSeriesOEE sales, _) => sales.time,
//             measureFn: (TimeSeriesOEE sales, _) => sales.oee,
//             data: oee[line.id] ?? [],
//           )
//         ];
//       }
//     });
//   }

//   Future<void> getShifts() async {
//     shifts = [];
//     await appStore.shiftApp.list({}).then((response) {
//       if (response.containsKey("status") && response["status"]) {
//         for (var item in response["payload"]) {
//           Shift shift = Shift.fromJSON(item);
//           shifts.add(shift);
//           late DateTime shiftStart, shiftEnd;
//           String startTime = shift.startTime;
//           String endTime = shift.endTime;
//           DateTime now = DateTime.now();
//           int hour = now.hour;
//           DateTime tomorrow = now.add(const Duration(days: 1));
//           DateTime yesterday = now.subtract(const Duration(days: 1));
//           int shiftStartHour = int.parse(shift.startTime.split(":")[0].toString());
//           int shiftEndHour = int.parse(shift.endTime.split(":")[0].toString());

//           if (shiftEndHour > shiftStartHour) {
//             shiftStart =
//                 DateTime(now.year, now.month, now.day, int.parse(startTime.split(":")[0].toString()), int.parse(startTime.split(":")[1].toString()));
//             shiftEnd =
//                 DateTime(now.year, now.month, now.day, int.parse(endTime.split(":")[0].toString()), int.parse(endTime.split(":")[1].toString()));
//           } else {
//             if (hour < 12) {
//               shiftStart = DateTime(yesterday.year, yesterday.month, yesterday.day, int.parse(startTime.split(":")[0].toString()),
//                   int.parse(startTime.split(":")[1].toString()));
//               shiftEnd =
//                   DateTime(now.year, now.month, now.day, int.parse(endTime.split(":")[0].toString()), int.parse(endTime.split(":")[1].toString()));
//             } else {
//               shiftStart = DateTime(
//                   now.year, now.month, now.day, int.parse(startTime.split(":")[0].toString()), int.parse(startTime.split(":")[1].toString()));
//               shiftEnd = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, int.parse(endTime.split(":")[0].toString()),
//                   int.parse(endTime.split(":")[1].toString()));
//             }
//           }

//           if (now.difference(shiftStart).inMinutes * now.difference(shiftEnd).inMinutes < 0) {
//             shiftStartTime = shiftStart;
//             shiftEndTime = shiftEnd;
//           }

//           if (oldShiftStartTime != shiftStartTime) {
//             productionByLineID = {};
//             availabilityByLineID = {};
//             performanceByLineID = {};
//             qualityByLineID = {};
//             oeeByLineID = {};
//             deviceByLineID = {};
//             totalPlannedDowntimeByLineID = {};
//             totalUnplannedDowntimeByLineID = {};
//             tasksByLineID = {};
//             plannedDowntimesByLineID = {};
//             unplannedDowntimesByLineID = {};
//             skusByLineID = {};
//             skuLlineSpeed = {};
//             availabilitySeriesData = {};
//             performanceSeriesData = {};
//             qualitySeriesData = {};
//             oeeSeriesData = {};
//             oldShiftStartTime = shiftStartTime;
//           }
//         }
//       }
//     });
//   }

//   Future<void> getData() async {
//     await Future.forEach([
//       await getRunTasks(),
//       await getDowntimes(),
//     ], (element) {})
//         .then((value) async {
//       await getSKUSpeeds();
//     }).then((value) async {
//       await getDevices();
//     }).then((value) async {
//       await getProduction();
//     }).then((value) async {
//       await getRunEfficiency();
//     });
//   }

//   Future<void> getDowntimes() async {
//     plannedDowntimesByLineID = {};
//     unplannedDowntimesByLineID = {};
//     controlledDowntimesByLineID = {};
//     Map<String, dynamic> conditions = {
//       "AND": [
//         {
//           "EQUALS": {
//             "Field": "line_id",
//             "Value": storage!.getString("line_id"),
//           },
//         },
//         {
//           "OR": [
//             {
//               "BETWEEN": {
//                 "Field": "start_time",
//                 "LowerValue": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//                 "HigherValue": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//               }
//             },
//             {
//               "BETWEEN": {
//                 "Field": "end_time",
//                 "LowerValue": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//                 "HigherValue": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//               }
//             },
//             {
//               "IS": {
//                 "Field": "end_time",
//                 "Value": "NULL",
//               },
//             },
//           ],
//         },
//       ]
//     };
//     await appStore.downtimeApp.list(conditions).then((response) {
//       if (response.containsKey("status") && response["status"]) {
//         for (var item in response["payload"]) {
//           Downtime downtime = Downtime.fromJSON(item);
//           downtime.planned
//               ? plannedDowntimesByLineID.containsKey(downtime.line.id)
//                   ? plannedDowntimesByLineID[downtime.line.id]!.add(downtime)
//                   : plannedDowntimesByLineID[downtime.line.id] = [downtime]
//               : downtime.controlled
//                   ? controlledDowntimesByLineID.containsKey(downtime.line.id)
//                       ? controlledDowntimesByLineID[downtime.line.id]!.add(downtime)
//                       : controlledDowntimesByLineID[downtime.line.id] = [downtime]
//                   : unplannedDowntimesByLineID.containsKey(downtime.line.id)
//                       ? unplannedDowntimesByLineID[downtime.line.id]!.add(downtime)
//                       : unplannedDowntimesByLineID[downtime.line.id] = [downtime];
//           DateTime downtimeShiftStartTime = downtime.startTime.difference(shiftStartTime).inSeconds < 0 ? shiftStartTime : downtime.startTime;
//           DateTime downtimeShiftEndTime = downtime.endTime.difference(DateTime.now()).inSeconds < 0
//               ? DateTime.now()
//               : downtime.endTime.difference(shiftEndTime).inSeconds < 0
//                   ? downtime.endTime
//                   : shiftEndTime;
//           if (downtime.planned) {
//             if (totalPlannedDowntimeByLineID.containsKey(downtime.line.id)) {
//               totalPlannedDowntimeByLineID[downtime.line.id] =
//                   totalPlannedDowntimeByLineID[downtime.line.id]! + downtimeShiftEndTime.difference(downtimeShiftStartTime).inSeconds;
//             } else {
//               totalPlannedDowntimeByLineID[downtime.line.id] = downtimeShiftEndTime.difference(downtimeShiftStartTime).inSeconds;
//             }
//           }

//           if (downtime.controlled) {
//             if (totalControlledDowntimeByLineID.containsKey(downtime.line.id)) {
//               totalControlledDowntimeByLineID[downtime.line.id] =
//                   totalControlledDowntimeByLineID[downtime.line.id]! + downtimeShiftEndTime.difference(downtimeShiftStartTime).inSeconds;
//             } else {
//               totalControlledDowntimeByLineID[downtime.line.id] = downtimeShiftEndTime.difference(downtimeShiftStartTime).inSeconds;
//             }
//           }

//           if (!downtime.controlled && !downtime.planned) {
//             if (totalUnplannedDowntimeByLineID.containsKey(downtime.line.id)) {
//               totalUnplannedDowntimeByLineID[downtime.line.id] =
//                   totalUnplannedDowntimeByLineID[downtime.line.id]! + downtimeShiftEndTime.difference(downtimeShiftStartTime).inSeconds;
//             } else {
//               totalUnplannedDowntimeByLineID[downtime.line.id] = downtimeShiftEndTime.difference(downtimeShiftStartTime).inSeconds;
//             }
//           }
//         }
//       }
//     });
//   }

//   Future<void> getRunTasks() async {
//     tasksByLineID = {};
//     skusByLineID = {};
//     lines = [];
//     Map<String, dynamic> conditions = {
//       "AND": [
//         {
//           "EQUALS": {
//             "Field": "line_id",
//             "Value": storage!.getString("line_id"),
//           },
//         },
//         {
//           "OR": [
//             {
//               "BETWEEN": {
//                 "Field": "start_time",
//                 "LowerValue": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//                 "HigherValue": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//               }
//             },
//             {
//               "BETWEEN": {
//                 "Field": "end_time",
//                 "LowerValue": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//                 "HigherValue": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//               }
//             },
//             {
//               "IS": {
//                 "Field": "end_time",
//                 "Value": "NULL",
//               },
//             },
//           ],
//         },
//       ]
//     };
//     await appStore.taskApp.list(conditions).then((response) {
//       if (response.containsKey("status") && response["status"]) {
//         for (var item in response["payload"]) {
//           Task task = Task.fromJSON(item);
//           if (tasksByLineID.containsKey(task.line.id)) {
//             tasksByLineID[task.line.id]!.add(task);
//           } else {
//             lines.add(task.line);
//             tasksByLineID[task.line.id] = [task];
//           }
//           if (skusByLineID.containsKey(task.line.id)) {
//             skusByLineID[task.line.id]!.add(task.job.sku.id);
//           } else {
//             skusByLineID[task.line.id] = [task.job.sku.id];
//           }
//         }
//       }
//     });
//   }

//   Future<void> getSKUSpeeds() async {
//     skuLlineSpeed = {};
//     skusByLineID.forEach((key, value) async {
//       Map<String, dynamic> conditions = {
//         "AND": [
//           {
//             "EQUALS": {
//               "Field": "line_id",
//               "Value": key,
//             }
//           },
//           {
//             "IN": {
//               "Field": "sku_id",
//               "Value": value,
//             }
//           },
//         ],
//       };
//       await appStore.skuSpeedApp.list(conditions).then((response) {
//         if (response.containsKey("status") && response["status"]) {
//           for (var item in response["payload"]) {
//             SKUSpeed skuSpeed = SKUSpeed.fromJSON(item);
//             skuLlineSpeed[skuSpeed.line.id + "_" + skuSpeed.sku.id] = skuSpeed.speed;
//           }
//         }
//       });
//     });
//   }

//   Future<void> getDevices() async {
//     deviceByLineID = {};
//     List<String> lineIDs = tasksByLineID.keys.toList();
//     Map<String, dynamic> conditions = {
//       "IN": {
//         "Field": "line_id",
//         "Value": lineIDs,
//       }
//     };
//     await appStore.deviceApp.list(conditions).then((response) {
//       if (response.containsKey("status") && response["status"]) {
//         for (var item in response["payload"]) {
//           Device device = Device.fromJSON(item);
//           if (device.useForOEE) {
//             deviceByLineID[device.line.id] = device.id;
//           }
//         }
//       }
//     });
//   }

//   Future<void> getProduction() async {
//     productionByLineID = {};
//     if (deviceByLineID.isNotEmpty) {
//       await Future.forEach([deviceByLineID], (element) async {
//         Map<String, dynamic> device = Map.from(element as Map<String, dynamic>);
//         String key = device.keys.toList()[0];
//         Map<String, dynamic> conditions = {
//           "AND": [
//             {
//               "EQUALS": {
//                 "Field": "device_id",
//                 "Value": device[key],
//               },
//             },
//             {
//               "GREATEREQUAL": {
//                 "Field": "created_at",
//                 "Value": shiftStartTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//               },
//             },
//             {
//               "LESSEQUAL": {
//                 "Field": "created_at",
//                 "Value": shiftEndTime.toUtc().toIso8601String().toString().split(".")[0] + "Z",
//               },
//             },
//           ]
//         };
//         await appStore.deviceDataApp.list(conditions).then((response) {
//           if (response.containsKey("status") && response["status"]) {
//             productionByLineID[key] = 0;
//             for (var item in response["payload"]) {
//               DeviceData deviceData = DeviceData.fromJSON(item);
//               if (deviceData.device.useForOEE) {
//                 productionByLineID[key] = productionByLineID[key]! + double.parse(deviceData.value.toString());
//               }
//             }
//           } else {
//             productionByLineID[key] = 0;
//           }
//         });
//       });
//     }
//   }

//   int getTaskDowntime(Task task, List<Downtime> downtimes) {
//     int time = 0;
//     for (var downtime in downtimes) {
//       DateTime taskDowntimeStartTime = task.startTime.difference(downtime.startTime).inSeconds < 0 ? downtime.startTime : task.startTime;
//       DateTime taskDowntimeEndTime = downtime.endTime.difference(DateTime.now()).inSeconds > 0
//           ? DateTime.now()
//           : downtime.endTime.difference(task.endTime).inSeconds < 0
//               ? downtime.endTime
//               : task.endTime;
//       if (taskDowntimeEndTime.difference(taskDowntimeStartTime).inSeconds > 0) {
//         time += taskDowntimeEndTime.difference(taskDowntimeStartTime).inSeconds;
//       }
//     }
//     return time;
//   }

//   int getTotalShiftDowntime(List<Downtime> downtimes) {
//     int totalDowntime = 0;
//     for (var downtime in downtimes) {
//       DateTime downtimeShiftStartTime = downtime.startTime.difference(shiftStartTime).inSeconds < 0 ? shiftStartTime : downtime.startTime;
//       DateTime downtimeShiftEndTime = downtime.endTime.difference(DateTime.now()).inSeconds > 0
//           ? DateTime.now()
//           : downtime.endTime.difference(shiftEndTime).inSeconds < 0
//               ? downtime.endTime
//               : shiftEndTime;
//       int time = downtimeShiftEndTime.difference(downtimeShiftStartTime).inSeconds;
//       totalDowntime += time;
//     }
//     return totalDowntime;
//   }

//   Future<void> getRunEfficiency() async {
//     for (var line in lines) {
//       int totalTaskPlannedDowntime = 0;
//       int totalTaskControlledDowntime = 0;
//       double theoreticalCount = 0, actualCount = productionByLineID[line.id] ?? 0;
//       for (var task in tasksByLineID[line.id]!) {
//         DateTime taskShiftStartTime = task.startTime.difference(shiftStartTime).inSeconds < 0 ? shiftStartTime : task.startTime;
//         DateTime taskShiftEndTime = task.endTime.difference(DateTime.now()).inSeconds > 0
//             ? DateTime.now()
//             : task.endTime.difference(shiftEndTime).inSeconds < 0
//                 ? task.endTime
//                 : shiftEndTime;
//         int taskTime = taskShiftEndTime.difference(taskShiftStartTime).inSeconds;
//         double speed = skuLlineSpeed[task.line.id + "_" + task.job.sku.id] ?? 0;
//         totalTaskPlannedDowntime += getTaskDowntime(task, plannedDowntimesByLineID[line.id] ?? []);
//         totalTaskControlledDowntime += getTaskDowntime(task, controlledDowntimesByLineID[line.id] ?? []);
//         theoreticalCount += (taskTime - totalTaskPlannedDowntime - totalTaskControlledDowntime) * speed / 60;
//       }
//       int totalShiftTime = DateTime.now().difference(shiftStartTime).inSeconds - getTotalShiftDowntime(controlledDowntimesByLineID[line.id] ?? []);
//       int availableTime = totalShiftTime;
//       int productionTime = availableTime -
//           getTotalShiftDowntime(plannedDowntimesByLineID[line.id] ?? []) -
//           getTotalShiftDowntime(unplannedDowntimesByLineID[line.id] ?? []);
//       double availability = productionTime / availableTime;
//       double performance = min(actualCount / theoreticalCount, 1);
//       double oee = availability * performance;
//       availabilityByLineID[line.id] = double.parse(availability.toStringAsFixed(2));
//       performanceByLineID[line.id] = double.parse(performance.toStringAsFixed(2));
//       qualityByLineID[line.id] = 1;
//       oeeByLineID[line.id] = double.parse(oee.toStringAsFixed(2));
//     }
//     setState(() {
//       isLoading = false;
//     });
//   }

//   List<charts.RangeAnnotationSegment<DateTime>> buildChart(String lineID) {
//     List<charts.RangeAnnotationSegment<DateTime>> chartData = [
//       charts.RangeAnnotationSegment(
//         shiftStartTime,
//         shiftEndTime,
//         charts.RangeAnnotationAxisType.domain,
//       ),
//     ];

//     if (plannedDowntimesByLineID.containsKey(lineID)) {
//       for (var down in plannedDowntimesByLineID[lineID]!) {
//         chartData.add(
//           charts.RangeAnnotationSegment(
//             down.startTime,
//             down.endTime,
//             charts.RangeAnnotationAxisType.domain,
//             labelAnchor: charts.AnnotationLabelAnchor.end,
//             color: charts.MaterialPalette.gray.shade400,
//             labelDirection: charts.AnnotationLabelDirection.horizontal,
//           ),
//         );
//       }
//     }

//     if (controlledDowntimesByLineID.containsKey(lineID)) {
//       for (var down in controlledDowntimesByLineID[lineID]!) {
//         chartData.add(
//           charts.RangeAnnotationSegment(
//             down.startTime,
//             down.endTime,
//             charts.RangeAnnotationAxisType.domain,
//             labelAnchor: charts.AnnotationLabelAnchor.end,
//             color: charts.MaterialPalette.gray.shade300,
//             labelDirection: charts.AnnotationLabelDirection.horizontal,
//           ),
//         );
//       }
//     }

//     if (unplannedDowntimesByLineID.containsKey(lineID)) {
//       for (var down in unplannedDowntimesByLineID[lineID]!) {
//         chartData.add(
//           charts.RangeAnnotationSegment(
//             down.startTime,
//             down.endTime,
//             charts.RangeAnnotationAxisType.domain,
//             labelAnchor: charts.AnnotationLabelAnchor.end,
//             color: charts.MaterialPalette.gray.shade500,
//             labelDirection: charts.AnnotationLabelDirection.horizontal,
//           ),
//         );
//       }
//     }

//     return chartData;
//   }

//   List<Widget> getCharts() {
//     var screenSize = MediaQuery.of(context).size;
//     List<Widget> widgets = [];
//     String lineID = storage!.getString("line_id") ?? "";
//     if (lineID != "") {
//       widgets.add(
//         Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Text(
//                   "Availability: " + availabilityByLineID[lineID]!.toStringAsFixed(2),
//                   style: TextStyle(
//                     color: isDarkTheme.value ? foregroundColor : backgroundColor,
//                     fontSize: 40.0,
//                   ),
//                 ),
//                 Text(
//                   "Performance: " + performanceByLineID[lineID]!.toStringAsFixed(2),
//                   style: TextStyle(
//                     color: isDarkTheme.value ? foregroundColor : backgroundColor,
//                     fontSize: 40.0,
//                   ),
//                 ),
//                 Text(
//                   "Quality: " + qualityByLineID[lineID]!.toStringAsFixed(2),
//                   style: TextStyle(
//                     color: isDarkTheme.value ? foregroundColor : backgroundColor,
//                     fontSize: 40.0,
//                   ),
//                 ),
//                 Text(
//                   "OEE: " + oeeByLineID[lineID]!.toStringAsFixed(2),
//                   style: TextStyle(
//                     color: isDarkTheme.value ? foregroundColor : backgroundColor,
//                     fontSize: 40.0,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               width: screenSize.width - 50,
//               height: screenSize.height - 150,
//               child: charts.TimeSeriesChart(
//                 oeeSeriesData[lineID] ?? [],
//                 animate: true,
//                 behaviors: [
//                   charts.SeriesLegend(
//                     position: charts.BehaviorPosition.end,
//                     entryTextStyle: charts.TextStyleSpec(
//                       color: charts.MaterialPalette.purple.shadeDefault,
//                       fontSize: 20,
//                     ),
//                   ),
//                   charts.RangeAnnotation(
//                     buildChart(lineID),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return widgets;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? Center(
//             child: CircularProgressIndicator(
//               backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
//               color: isDarkTheme.value ? backgroundColor : foregroundColor,
//             ),
//           )
//         : deviceByLineID.isEmpty
//             ? Center(
//                 child: Text(
//                   "Line Not Running",
//                   style: TextStyle(
//                     color: isDarkTheme.value ? foregroundColor : backgroundColor,
//                   ),
//                 ),
//               )
//             : Container(
//                 decoration: const BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                   color: Color(0xFFFEFBE7),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Line: " +
//                           lines.where((element) => element.id == storage!.getString("line_id")).toString().replaceAll("(", "").replaceAll(")", ""),
//                       style: TextStyle(
//                         color: isDarkTheme.value ? foregroundColor : backgroundColor,
//                         fontSize: 40.0,
//                       ),
//                     ),
//                     Wrap(
//                       alignment: WrapAlignment.spaceEvenly,
//                       children: getCharts(),
//                     ),
//                   ],
//                 ),
//               );
//   }
// }
