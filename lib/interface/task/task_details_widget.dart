import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/device.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/domain/entity/task_batch.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/lists/downtime.dart';
import 'package:oees/interface/common/lists/task_batches.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/task/task_list_widget.dart';

class TaskDetailsWidget extends StatefulWidget {
  final Task task;
  const TaskDetailsWidget({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskDetailsWidget> createState() => _TaskDetailsWidgetState();
}

class _TaskDetailsWidgetState extends State<TaskDetailsWidget> {
  late Timer timer;
  bool autoReload = true;
  bool isLoading = true;
  double taskUnits = 0;
  List<Downtime> downtimes = [];
  List<TaskBatch> taskBatches = [];
  Map<String, double> taskBatchDeviceData = {};
  Map<String, dynamic> batchUnits = {};
  late TextEditingController batchController, batchSizeController;

  @override
  void initState() {
    getTaskDetails();
    timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      getTaskDetails();
    });
    batchController = TextEditingController();
    batchSizeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  double getBatchUnits(TaskBatch batch) {
    double batchCounts = 0;
    if (taskBatchDeviceData.containsKey(batch.id)) {
      batchCounts = taskBatchDeviceData[batch.id] ?? 0;
    }
    return batchCounts;
  }

  void getTaskDetails() async {
    taskBatches = [];
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
    }
    DateTime taskEndTime = DateTime.parse("1900-01-01T00:00:00Z").toLocal();
    DateTime taskStartTime = DateTime.parse("2099-12-31T23:59:59Z").toLocal();
    await appStore.taskBatchApp.list(widget.task.id).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          TaskBatch thisTaskBatch = TaskBatch.fromJSON(item);
          taskBatches.add(thisTaskBatch);
          DateTime startTime = thisTaskBatch.startTime.toLocal();
          DateTime endTime = thisTaskBatch.endTime.toLocal();
          if (taskEndTime.difference(endTime).inSeconds < 0) {
            taskEndTime = endTime;
          }
          if (taskStartTime.difference(startTime).inSeconds > 0) {
            taskStartTime = startTime;
          }
        }
      }
      if (taskEndTime.difference(DateTime.now().toLocal()).inSeconds > 0) {
        taskEndTime = DateTime.now().toLocal();
      }
      await Future.wait([getDeviceData(), getDowntimeData(taskStartTime, taskEndTime)]).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  Future<void> getDeviceData() async {
    taskBatchDeviceData = {};
    String lineID = widget.task.line.id;
    String deviceID = "";
    Map<String, dynamic> lineConditions = {
      "EQUALS": {
        "Field": "line_id",
        "Value": lineID,
      }
    };
    await appStore.deviceApp.list(lineConditions).then((value) async {
      if (value.containsKey("status") && value["status"]) {
        for (var item in value["payload"]) {
          Device thisDevice = Device.fromJSON(item);
          if (thisDevice.useForOEE) {
            deviceID = thisDevice.id;
          }
        }
        if (deviceID != "") {
          await Future.wait(taskBatches.map((element) async {
            Map<String, dynamic> conditions = {
              "AND": [
                {
                  "EQUALS": {
                    "Field": "device_id",
                    "Value": deviceID,
                  },
                },
                {
                  "BETWEEN": {
                    "Field": "created_at",
                    "LowerValue": element.startTime.toUtc().toString().substring(0, 10) + "T" + element.startTime.toUtc().toString().substring(11, 19) + "Z",
                    "HigherValue": element.endTime.toUtc().toString().substring(0, 10) + "T" + element.endTime.toUtc().toString().substring(11, 19) + "Z",
                  }
                }
              ],
            };
            await appStore.deviceDataApp.totalDeviceData(conditions).then((response) {
              if (response.containsKey("status") && response["status"]) {
                taskBatchDeviceData[element.id] = double.parse(response["payload"]["value"].toString());
                taskUnits += double.parse(response["payload"]["value"].toString());
              }
            });
          }));
        }
      }
    });
  }

  Future<void> getDowntimeData(DateTime startTime, DateTime endTime) async {
    downtimes = [];
    startTime = startTime.toUtc();
    endTime = endTime.toUtc();
    Map<String, dynamic> conditions = {
      "AND": [
        {
          "EQUALS": {
            "Field": "line_id",
            "Value": widget.task.line.id,
          },
        },
        {
          "OR": [
            {
              "BETWEEN": {
                "Field": "start_time",
                "LowerValue": startTime.toUtc().toString().substring(0, 10) + "T" + startTime.toString().substring(11, 19) + "Z",
                "HigherValue": endTime.toString().substring(0, 10) + "T" + endTime.toString().substring(11, 19) + "Z",
              }
            },
            {
              "BETWEEN": {
                "Field": "end_time",
                "LowerValue": startTime.toString().substring(0, 10) + "T" + startTime.toString().substring(11, 19) + "Z",
                "HigherValue": endTime.toString().substring(0, 10) + "T" + endTime.toString().substring(11, 19) + "Z",
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
          if (currentUser.userRole.description == "Line Manager") {
            if (downtime.description == "" || downtime.description.isEmpty) {
              downtimes.add(downtime);
            }
          } else {
            downtimes.add(downtime);
          }
        }
      }
    });
  }

  Widget buildRow(String title, dynamic data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 350,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                color: isDarkTheme.value ? foregroundColor.withOpacity(0.75) : backgroundColor.withOpacity(0.75),
              ),
            ),
          ),
          Text(
            data.toString(),
            style: TextStyle(
              fontSize: 20.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool allDowntimesUpdated() {
    bool updated = true;
    for (var downtime in downtimes) {
      updated = updated && (downtime.description != "" || downtime.preset != "") && downtime.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0;
    }
    return updated;
  }

  refresh(List<Downtime> createdDowntimes) {
    downtimes.addAll(createdDowntimes);
    downtimes.sort(
      (a, b) => b.startTime.compareTo(a.startTime),
    );
    setState(() {});
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
            : SuperWidget(childWidget: BaseWidget(
                builder: (context, screenSizeInfo) {
                  return SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  navigationService.pushReplacement(
                                    CupertinoPageRoute(
                                      builder: (BuildContext context) => const TaskListWidget(),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                  size: 40.0,
                                ),
                              ),
                            ),
                            Text(
                              "Task Details",
                              style: TextStyle(
                                fontSize: 40.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 20.0,
                          color: Colors.transparent,
                        ),
                        Row(
                          children: [
                            widget.task.startTime.difference(DateTime.parse("1900-01-01T00:00:00Z")).inSeconds == 0
                                ? Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: MaterialButton(
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Enter Batch Details'),
                                              content: SizedBox(
                                                height: 400,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextField(
                                                      onChanged: (value) {},
                                                      controller: batchController,
                                                      decoration: const InputDecoration(hintText: "Enter Batch#"),
                                                    ),
                                                    TextField(
                                                      onChanged: (value) {},
                                                      controller: batchSizeController,
                                                      decoration: const InputDecoration(hintText: "Enter Batch Size (KG)"),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                MaterialButton(
                                                  color: Colors.green,
                                                  textColor: Colors.white,
                                                  child: const Padding(
                                                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                                    child: Text('OK'),
                                                  ),
                                                  onPressed: () async {
                                                    String batchNo = batchController.text;
                                                    double batchSize = double.parse(batchSizeController.text.toString());
                                                    String errors = "";
                                                    if (batchNo.isEmpty || batchNo == "") {
                                                      errors += "Batch Number Missing\n";
                                                    }
                                                    if (batchSizeController.text.isEmpty || batchSizeController.text == "") {
                                                      errors += "Batch Size Missing\n";
                                                    }
                                                    if (errors.isNotEmpty) {
                                                      setState(() {
                                                        Navigator.pop(context);
                                                        isError = true;
                                                        errorMessage = errors;
                                                      });
                                                    } else {
                                                      DateTime now = DateTime.now().toUtc();
                                                      String time = now.toString().substring(0, 10) + "T" + now.toString().substring(11, 19) + "Z";
                                                      Map<String, dynamic> taskBatch = {
                                                        "task_id": widget.task.id,
                                                        "batch_number": batchNo,
                                                        "batch_size": batchSize,
                                                        "start_time": time,
                                                        "created_by_username": currentUser.username,
                                                        "updated_by_username": currentUser.username,
                                                      };
                                                      Map<String, dynamic> checkLineRunningTaskCondition = {
                                                        "AND": [
                                                          {
                                                            "EQUALS": {
                                                              "Field": "line_id",
                                                              "Value": widget.task.line.id,
                                                            }
                                                          },
                                                          {
                                                            "EQUALS": {
                                                              "Field": "complete",
                                                              "Value": "0",
                                                            },
                                                          },
                                                          {
                                                            "IS": {
                                                              "Field": "start_time",
                                                              "Value": "NOT NULL",
                                                            },
                                                          },
                                                        ]
                                                      };
                                                      await appStore.taskApp.list(checkLineRunningTaskCondition).then((value) async {
                                                        if (value.containsKey("status") && value["status"]) {
                                                          if (value["payload"].length != 0) {
                                                            Task runningTask = Task.fromJSON(value["payload"][0]);
                                                            setState(() {
                                                              isError = true;
                                                              errorMessage = "Job" + runningTask.job.code + " is already running on the line";
                                                            });
                                                          } else {
                                                            await appStore.taskBatchApp.create(taskBatch).then((response) async {
                                                              if (response.containsKey("status") && response["status"]) {
                                                                TaskBatch newBatch = TaskBatch.fromJSON(response["payload"]);
                                                                taskBatches.add(newBatch);
                                                                Map<String, dynamic> update = {
                                                                  "start_time": time,
                                                                  "updated_by_username": currentUser.username,
                                                                };
                                                                await appStore.taskApp.update(widget.task.id, update).then((taskResponse) {
                                                                  if (taskResponse.containsKey("status") && taskResponse["status"]) {
                                                                    widget.task.startTime = now;
                                                                    setState(() {});
                                                                  } else {
                                                                    setState(() {
                                                                      isError = true;
                                                                      errorMessage = "Unable to start Task, please try later";
                                                                    });
                                                                  }
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  isError = true;
                                                                  errorMessage = "Unable to start Task, please try later";
                                                                });
                                                              }
                                                            });
                                                          }
                                                        } else {
                                                          setState(() {
                                                            isError = true;
                                                            errorMessage = "Unable to Begin Task";
                                                          });
                                                        }
                                                      });
                                                    }
                                                    setState(() {
                                                      batchController.clear();
                                                      Navigator.of(context).pop();
                                                    });
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      color: foregroundColor,
                                      height: 60.0,
                                      minWidth: 50.0,
                                      child: const Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                        child: Text(
                                          "Start Task",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : widget.task.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: MaterialButton(
                                          onPressed: () async {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text('Enter Batch Details'),
                                                  content: Wrap(
                                                    children: [
                                                      TextField(
                                                        onChanged: (value) {},
                                                        controller: batchController,
                                                        decoration: const InputDecoration(hintText: "Enter Batch#"),
                                                      ),
                                                      TextField(
                                                        onChanged: (value) {},
                                                        controller: batchSizeController,
                                                        decoration: const InputDecoration(hintText: "Enter Batch Size (KG)"),
                                                      )
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    MaterialButton(
                                                      color: Colors.green,
                                                      textColor: Colors.white,
                                                      child: const Padding(
                                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                                        child: Text('OK'),
                                                      ),
                                                      onPressed: () async {
                                                        String errors = "";
                                                        if (batchController.text.isEmpty || batchController.text == "") {
                                                          errors += "Batch Number Missing\n";
                                                        }
                                                        if (batchSizeController.text.isEmpty || batchSizeController.text == "") {
                                                          errors += "Batch Size Missing\n";
                                                        }
                                                        if (errors.isNotEmpty) {
                                                          setState(() {
                                                            isError = true;
                                                            errorMessage = errors;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            Navigator.of(context).pop();
                                                            isLoading = true;
                                                          });
                                                          String batchNo = batchController.text;
                                                          double batchSize = double.parse(batchSizeController.text.toString());
                                                          DateTime now = DateTime.now().toUtc();
                                                          String time = now.toString().substring(0, 10) + "T" + now.toString().substring(11, 19) + "Z";
                                                          Map<String, dynamic> taskBatch = {
                                                            "task_id": widget.task.id,
                                                            "batch_number": batchNo,
                                                            "batch_size": batchSize,
                                                            "start_time": time,
                                                            "created_by_username": currentUser.username,
                                                            "updated_by_username": currentUser.username,
                                                          };
                                                          Map<String, dynamic> currentBatchUpdate = {
                                                            "end_time": time,
                                                            "complete": true,
                                                            "updated_by_username": currentUser.username,
                                                          };
                                                          TaskBatch currentBatch =
                                                              taskBatches.firstWhere((element) => element.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds >= 0);
                                                          await appStore.taskBatchApp.update(currentBatch.id, currentBatchUpdate).then((response) async {
                                                            if (response.containsKey("status") && response["status"]) {
                                                              await appStore.taskBatchApp.create(taskBatch).then((batchResponse) {
                                                                if (batchResponse.containsKey("status") && batchResponse["status"]) {
                                                                  currentBatch.endTime = now.toLocal();
                                                                  taskBatches.removeWhere((element) => element.id == currentBatch.id);
                                                                  taskBatches.add(currentBatch);
                                                                  TaskBatch newBatch = TaskBatch.fromJSON(batchResponse["payload"]);
                                                                  taskBatches.add(newBatch);
                                                                  taskBatches.sort(((a, b) => a.batchNumber.compareTo(b.batchNumber)));
                                                                  setState(() {
                                                                    isLoading = false;
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    isLoading = false;
                                                                    isError = true;
                                                                    errorMessage = "Unable to start new Batch, please try later";
                                                                  });
                                                                }
                                                              });
                                                            } else {
                                                              setState(() {
                                                                isLoading = false;
                                                                isError = true;
                                                                errorMessage = "Unable to start new Batch, please try later";
                                                              });
                                                            }
                                                          });
                                                        }
                                                        setState(() {
                                                          isLoading = false;
                                                          batchController.clear();
                                                          batchSizeController.clear();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          color: foregroundColor,
                                          height: 60.0,
                                          minWidth: 50.0,
                                          child: const Padding(
                                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                            child: Text(
                                              "Change Batch",
                                              style: TextStyle(
                                                fontSize: 20.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                            widget.task.startTime.difference(DateTime.parse("1900-01-01T00:00:00Z")).inSeconds == 0
                                ? Container()
                                : widget.task.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: MaterialButton(
                                          onPressed: () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            DateTime now = DateTime.now().toUtc();
                                            String time = now.toString().substring(0, 10) + "T" + now.toString().substring(11, 19) + "Z";
                                            Map<String, dynamic> currentBatchUpdate = {
                                              "end_time": time,
                                              "complete": true,
                                              "updated_by_username": currentUser.username,
                                            };
                                            TaskBatch currentBatch = taskBatches.firstWhere((element) => element.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds >= 0);

                                            if (allDowntimesUpdated()) {
                                              await appStore.taskBatchApp.update(currentBatch.id, currentBatchUpdate).then((response) async {
                                                if (response.containsKey("status") && response["status"]) {
                                                  await appStore.taskApp.update(widget.task.id, currentBatchUpdate).then((newResponse) {
                                                    if (newResponse.containsKey("status") && newResponse["status"]) {
                                                      currentBatch.endTime = now.toLocal();
                                                      taskBatches.removeWhere((element) => element.id == currentBatch.id);
                                                      taskBatches.add(currentBatch);
                                                      widget.task.endTime = now.toLocal();
                                                      widget.task.running = false;
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        isLoading = false;
                                                        isError = true;
                                                        errorMessage = "Unable to end Task, please try later.";
                                                      });
                                                    }
                                                  });
                                                } else {
                                                  setState(() {
                                                    isLoading = false;
                                                    isError = true;
                                                    errorMessage = "Unable to end Task, please try later.";
                                                  });
                                                }
                                              });
                                            } else {
                                              setState(() {
                                                isLoading = false;
                                                isError = true;
                                                errorMessage = "Update All Downtimes Before Ending Task";
                                              });
                                            }
                                          },
                                          color: foregroundColor,
                                          height: 60.0,
                                          minWidth: 50.0,
                                          child: const Padding(
                                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                            child: Text(
                                              "End Task",
                                              style: TextStyle(
                                                fontSize: 20.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                            // formFieldWidget.render(),
                            const VerticalDivider(
                              width: 15,
                              color: Colors.transparent,
                            ),
                            autoReload
                                ? MaterialButton(
                                    child: Text(
                                      "Stop Autoreload",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkTheme.value ? backgroundColor.withOpacity(0.75) : foregroundColor.withOpacity(0.75),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        autoReload = !autoReload;
                                        timer.cancel();
                                      });
                                    },
                                    color: foregroundColor,
                                    height: 60.0,
                                    minWidth: 50.0,
                                  )
                                : Container(),
                          ],
                        ),
                        const Divider(
                          height: 20.0,
                          color: Colors.transparent,
                        ),
                        buildRow("Task ID", widget.task.id),
                        buildRow("Job Code", widget.task.job.code),
                        buildRow("Line", widget.task.line.name),
                        buildRow("Product Code", widget.task.job.sku.code),
                        buildRow("Product Description", widget.task.job.sku.description),
                        buildRow("Scheduled Run", widget.task.scheduledDate.toLocal().toString().substring(0, 10)),
                        buildRow("Plan", numberFormat.format(widget.task.job.plan)),
                        buildRow("Produced", numberFormat.format(taskUnits)),
                        buildRow("Status", widget.task.running.toString().toUpperCase()),
                        buildRow("Production Started",
                            widget.task.startTime.difference(DateTime.parse("1900-01-01T00:00:00Z").toLocal()).inSeconds > 0 ? widget.task.startTime.toLocal().toString().substring(0, 16) : "-"),
                        buildRow("Production Completed",
                            widget.task.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds < 0 ? widget.task.endTime.toLocal().toString().substring(0, 16) : "-"),
                        const Divider(
                          height: 20.0,
                          color: Colors.transparent,
                        ),
                        const Divider(
                          height: 50.0,
                          color: Colors.transparent,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                downtimes.isNotEmpty
                                    ? Text(
                                        "Stoppages",
                                        style: TextStyle(
                                          fontSize: 40.0,
                                          color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Container(),
                                downtimes.isNotEmpty
                                    ? SizedBox(
                                        child: DowntimeList(
                                          downtimes: downtimes,
                                          notifyParent: refresh,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            Column(
                              children: [
                                taskBatches.isNotEmpty
                                    ? Text(
                                        "Batches Run",
                                        style: TextStyle(
                                          fontSize: 40.0,
                                          color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Container(),
                                taskBatches.isNotEmpty
                                    ? SizedBox(
                                        child: TaskBatchesList(
                                          taskBatches: taskBatches,
                                          batchUnits: taskBatchDeviceData,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                        const Divider(
                          height: 50.0,
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  );
                },
              ), errorCallback: () {
                setState(
                  () {
                    isError = false;
                    errorMessage = "";
                  },
                );
              });
      },
    );
  }
}
