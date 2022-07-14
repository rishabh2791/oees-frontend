import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/domain/entity/task_batch.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/lists/task_batches.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

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
  bool isLoading = true;
  List<Downtime> downtimes = [];
  List<TaskBatch> taskBatches = [];
  late TextEditingController batchController;

  @override
  void initState() {
    getTaskDetails();
    batchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getTaskDetails() async {
    taskBatches = [];
    Map<String, dynamic> deviceDataConditions = {
      "IN": {
        "Field": "",
        "Value": [],
      }
    };
    await appStore.taskBatchApp.list(widget.task.id).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          TaskBatch thisTaskBatch = TaskBatch.fromJSON(item);
          taskBatches.add(thisTaskBatch);
          Map<String, dynamic> thisCondition = {};
          DateTime startTime = thisTaskBatch.startTime;
          DateTime endTime = thisTaskBatch.endTime;
          if (thisTaskBatch.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds < 0) {
            thisCondition = {
              "AND": [
                {
                  "GREATEREQUAL": {
                    "Field": "start_time",
                    "Value": startTime,
                  },
                },
                {
                  "LESSEQUAL": {
                    "Field": "end_time",
                    "Value": endTime,
                  },
                },
              ]
            };
          } else {
            thisCondition = {};
          }
        }
      }
      setState(() {
        isLoading = false;
      });
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
                        Text(
                          "Job Details",
                          style: TextStyle(
                            fontSize: 40.0,
                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                            fontWeight: FontWeight.bold,
                          ),
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
                                              title: const Text('Enter Batch#'),
                                              content: TextField(
                                                onChanged: (value) {},
                                                controller: batchController,
                                                decoration: const InputDecoration(hintText: "Enter Batch#"),
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
                                                    if (batchNo.isEmpty || batchNo == "") {
                                                      setState(() {
                                                        Navigator.pop(context);
                                                        isError = true;
                                                        errorMessage = "Need Batch# to start Task";
                                                      });
                                                    } else {
                                                      DateTime now = DateTime.now().toUtc();
                                                      String time = now.toString().substring(0, 10) + "T" + now.toString().substring(11, 19) + "Z";
                                                      Map<String, dynamic> taskBatch = {
                                                        "task_id": widget.task.id,
                                                        "batch_number": batchNo,
                                                        "start_time": time,
                                                        "created_by_username": currentUser.username,
                                                        "updated_by_username": currentUser.username,
                                                      };
                                                      await appStore.taskBatchApp.create(taskBatch).then((response) async {
                                                        if (response.containsKey("status") && response["status"]) {
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
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: MaterialButton(
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Enter New Batch#'),
                                              content: TextField(
                                                onChanged: (value) {},
                                                controller: batchController,
                                                decoration: const InputDecoration(hintText: "Enter New Batch#"),
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
                                                    if (batchNo.isEmpty || batchNo == "") {
                                                      setState(() {
                                                        Navigator.pop(context);
                                                        isError = true;
                                                        errorMessage = "Need Batch# to start new Batch";
                                                      });
                                                    } else {
                                                      DateTime now = DateTime.now().toUtc();
                                                      String time = now.toString().substring(0, 10) + "T" + now.toString().substring(11, 19) + "Z";
                                                      Map<String, dynamic> taskBatch = {
                                                        "task_id": widget.task.id,
                                                        "batch_number": batchNo,
                                                        "start_time": time,
                                                        "created_by_username": currentUser.username,
                                                        "updated_by_username": currentUser.username,
                                                      };
                                                      Map<String, dynamic> currentBatchUpdate = {
                                                        "end_time": time,
                                                        "updated_by_username": currentUser.username,
                                                      };
                                                      TaskBatch currentBatch = taskBatches.firstWhere((element) =>
                                                          element.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds >=
                                                          0);

                                                      await appStore.taskBatchApp.update(currentBatch.id, currentBatchUpdate).then((response) async {
                                                        if (response.containsKey("status") && response["status"]) {
                                                          await appStore.taskBatchApp.create(taskBatch).then((newResponse) {
                                                            if (newResponse.containsKey("status") && newResponse["status"]) {
                                                              currentBatch.endTime = now.toLocal();
                                                              taskBatches.removeWhere((element) => element.id == currentBatch.id);
                                                              taskBatches.add(currentBatch);
                                                              TaskBatch newBatch = TaskBatch.fromJSON(newResponse["payload"]);
                                                              taskBatches.add(newBatch);
                                                              taskBatches.sort(((a, b) => a.batchNumber.compareTo(b.batchNumber)));
                                                              setState(() {});
                                                            } else {
                                                              setState(() {
                                                                isError = true;
                                                                errorMessage = "Unable to start new Batch, please try later";
                                                              });
                                                            }
                                                          });
                                                        } else {
                                                          setState(() {
                                                            isError = true;
                                                            errorMessage = "Unable to start new Batch, please try later";
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
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: MaterialButton(
                                      onPressed: () async {
                                        DateTime now = DateTime.now().toUtc();
                                        String time = now.toString().substring(0, 10) + "T" + now.toString().substring(11, 19) + "Z";
                                        Map<String, dynamic> currentBatchUpdate = {
                                          "end_time": time,
                                          "updated_by_username": currentUser.username,
                                        };
                                        TaskBatch currentBatch = taskBatches.firstWhere(
                                            (element) => element.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds >= 0);

                                        await appStore.taskBatchApp.update(currentBatch.id, currentBatchUpdate).then((response) async {
                                          if (response.containsKey("status") && response["status"]) {
                                            await appStore.taskApp.update(widget.task.id, currentBatchUpdate).then((newResponse) {
                                              if (newResponse.containsKey("status") && newResponse["status"]) {
                                                currentBatch.endTime = now.toLocal();
                                                taskBatches.removeWhere((element) => element.id == currentBatch.id);
                                                taskBatches.add(currentBatch);
                                                widget.task.endTime = now.toLocal();
                                                widget.task.running = false;
                                                setState(() {});
                                              } else {
                                                setState(() {
                                                  isError = true;
                                                  errorMessage = "Unable to end Task, please try later.";
                                                });
                                              }
                                            });
                                          } else {
                                            setState(() {
                                              isError = true;
                                              errorMessage = "Unable to end Task, please try later.";
                                            });
                                          }
                                        });
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
                        buildRow("Plan", widget.task.job.plan.toStringAsFixed(0)),
                        buildRow("Produced", 0), //TODO change this later
                        buildRow("Status", widget.task.running.toString().toUpperCase()),
                        buildRow(
                            "Production Started",
                            widget.task.startTime.difference(DateTime.parse("1900-01-01T00:00:00Z").toLocal()).inSeconds > 0
                                ? widget.task.startTime.toLocal().toString().substring(0, 16)
                                : "-"),
                        buildRow(
                            "Production Completed",
                            widget.task.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds < 0
                                ? widget.task.endTime.toLocal().toString().substring(0, 16)
                                : "-"),
                        const Divider(
                          height: 20.0,
                          color: Colors.transparent,
                        ),
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
                                width: 700,
                                child: TaskBatchesList(
                                  taskBatches: taskBatches,
                                ),
                              )
                            : Container(),
                        const Divider(
                          height: 20.0,
                          color: Colors.transparent,
                        ),
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
                                width: 700,
                                //TODO correct this.
                                child: TaskBatchesList(
                                  taskBatches: taskBatches,
                                ),
                              )
                            : Container(),
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
