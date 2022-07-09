import 'package:flutter/material.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
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

  @override
  void initState() {
    getTaskDetails();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getTaskDetails() {
    setState(() {
      isLoading = false;
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
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: MaterialButton(
                                onPressed: () async {},
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: MaterialButton(
                                onPressed: () async {},
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
                                ? widget.task.startTime.toLocal().toString()
                                : "-"),
                        buildRow(
                            "Production Completed",
                            widget.task.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds < 0
                                ? widget.task.endTime.toLocal().toString()
                                : "-"),
                        const Divider(
                          height: 20.0,
                          color: Colors.transparent,
                        ),
                        Text(
                          "Stoppages",
                          style: TextStyle(
                            fontSize: 40.0,
                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                            fontWeight: FontWeight.bold,
                          ),
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
