import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';
import 'package:oees/interface/common/ui_elements/delete_button.dart';
import 'package:oees/interface/common/ui_elements/update_button.dart';
import 'package:oees/interface/task/task_details_widget.dart';
import 'package:oees/interface/task/task_list_widget.dart';
import 'package:oees/interface/task/task_update_widget.dart';

class TaskList extends StatefulWidget {
  final List<Task> tasks;
  const TaskList({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  bool sort = true, ascending = true;
  int sortingColumnIndex = 0;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  onSortColum(int columnIndex, bool ascending) {
    switch (columnIndex) {
      case 0:
        if (ascending) {
          widget.tasks.sort((a, b) => a.line.name.compareTo(b.line.name));
        } else {
          widget.tasks.sort((a, b) => b.line.name.compareTo(a.line.name));
        }
        break;
      case 1:
        if (ascending) {
          widget.tasks.sort((a, b) => a.job.code.compareTo(b.job.code));
        } else {
          widget.tasks.sort((a, b) => b.job.code.compareTo(a.job.code));
        }
        break;
      case 2:
        if (ascending) {
          widget.tasks.sort((a, b) => a.job.sku.code.compareTo(b.job.sku.code));
        } else {
          widget.tasks.sort((a, b) => b.job.sku.code.compareTo(a.job.sku.code));
        }
        break;
      case 3:
        if (ascending) {
          widget.tasks.sort((a, b) => a.job.sku.description.compareTo(b.job.sku.description));
        } else {
          widget.tasks.sort((a, b) => b.job.sku.description.compareTo(a.job.sku.description));
        }
        break;
      case 4:
        if (ascending) {
          widget.tasks.sort((a, b) => a.job.plan.compareTo(b.job.plan));
        } else {
          widget.tasks.sort((a, b) => b.job.plan.compareTo(a.job.plan));
        }
        break;
      case 5:
        if (ascending) {
          widget.tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
        } else {
          widget.tasks.sort((a, b) => b.startTime.compareTo(a.startTime));
        }
        break;
      case 6:
        if (ascending) {
          widget.tasks.sort((a, b) => a.endTime.compareTo(b.endTime));
        } else {
          widget.tasks.sort((a, b) => b.endTime.compareTo(a.endTime));
        }
        break;
      default:
        break;
    }
  }

  void refresh(String id) {
    navigationService.pushReplacement(
      CupertinoPageRoute(
        builder: (BuildContext context) => const TaskListWidget(),
      ),
    );
  }

  Widget listDetailsWidget() {
    return BaseWidget(
      builder: (context, sizeInfo) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          width: sizeInfo.screenSize.width,
          height: widget.tasks.length <= 25 ? 156 + widget.tasks.length * 56 : 156 + 25 * 56,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: isDarkTheme.value ? backgroundColor : foregroundColor,
                    dividerColor:
                        isDarkTheme.value ? foregroundColor.withOpacity(0.25) : backgroundColor.withOpacity(0.25),
                    textTheme: TextTheme(
                      caption: TextStyle(
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                      ),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      PaginatedDataTable(
                        arrowHeadColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                        showCheckboxColumn: false,
                        showFirstLastButtons: true,
                        sortAscending: sort,
                        sortColumnIndex: sortingColumnIndex,
                        columnSpacing: 20.0,
                        columns: [
                          DataColumn(
                            label: Text(
                              "Line",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                sortingColumnIndex = columnIndex;
                              });
                              onSortColum(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Text(
                              "Job Code",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                sortingColumnIndex = columnIndex;
                              });
                              onSortColum(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Text(
                              "Material Code",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                sortingColumnIndex = columnIndex;
                              });
                              onSortColum(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Text(
                              "Material Description",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                sortingColumnIndex = columnIndex;
                              });
                              onSortColum(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Text(
                              "Plan (Units)",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                sortingColumnIndex = columnIndex;
                              });
                              onSortColum(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Text(
                              "Start Time",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                sortingColumnIndex = columnIndex;
                              });
                              onSortColum(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Text(
                              "End Time",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                sortingColumnIndex = columnIndex;
                              });
                              onSortColum(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Text(
                              " ",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                sortingColumnIndex = columnIndex;
                              });
                              onSortColum(columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Text(
                              " ",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                sortingColumnIndex = columnIndex;
                              });
                              onSortColum(columnIndex, ascending);
                            },
                          ),
                        ],
                        source: _DataSource(context, widget.tasks, refresh),
                        rowsPerPage: widget.tasks.length > 25 ? 25 : widget.tasks.length,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 40.0,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return listDetailsWidget();
  }
}

class _DataSource extends DataTableSource {
  _DataSource(this.context, this._tasks, this._callback) {
    _tasks = _tasks;
    _callback = _callback;
  }

  final BuildContext context;
  List<Task> _tasks;
  Function _callback;

  Future<void> _displayTextInputDialog(BuildContext context, Task task) async {
    return showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
          ),
          child: Container(
            color: Colors.white.withOpacity(0.6),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: TaskUpdateWidget(
                task: task,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _displayError(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
          ),
          child: Container(
            color: Colors.black.withOpacity(0.6),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: foregroundColor,
                      fontSize: 30.0,
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    color: foregroundColor,
                    height: 60.0,
                    minWidth: 50.0,
                    child: clearButton(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final task = _tasks[index];

    return DataRow.byIndex(
      index: index,
      selected: task.selected,
      onSelectChanged: (value) {
        if (task.selected != value) {
          task.selected = value!;
          notifyListeners();
          navigationService.pushReplacement(
            CupertinoPageRoute(
              builder: (BuildContext context) => TaskDetailsWidget(
                task: task,
              ),
            ),
          );
        }
      },
      cells: [
        DataCell(
          Text(
            task.line.name,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            task.job.code.toString(),
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            task.job.sku.code.toString(),
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            task.job.sku.description,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            task.job.plan.toStringAsFixed(0).replaceAllMapped(reg, (Match match) => '${match[1]},'),
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            task.startTime.difference(DateTime.parse("1900-01-01T00:00:00Z").toLocal()).inSeconds > 0
                ? task.startTime.toLocal().toString().split(".")[0]
                : "",
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            task.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds < 0
                ? task.endTime.toLocal().toString().split(".")[0]
                : "",
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        getAccessCode("tasks", "update") == "1"
            ? DataCell(
                MaterialButton(
                  onPressed: () async {
                    if (task.startTime.difference(DateTime.parse("1900-01-01T00:00:00Z").toLocal()).inSeconds <= 0) {
                      _displayTextInputDialog(context, task);
                    } else {
                      _displayError(context, "Started Task Cannot Be Updated.");
                    }
                  },
                  child: updateButton(),
                ),
              )
            : DataCell(
                Text(
                  " ",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDarkTheme.value ? foregroundColor : backgroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        getAccessCode("tasks", "delete") == "1"
            ? DataCell(
                MaterialButton(
                  onPressed: () async {
                    if (task.startTime.difference(DateTime.parse("1900-01-01T00:00:00Z").toLocal()).inSeconds <= 0) {
                      await appStore.taskApp.delete(task.id).then((response) async {
                        if (response.containsKey("status") && response["status"]) {
                          _callback(task.id);
                        }
                      });
                    } else {
                      _displayError(context, "Started Task Cannot Be Deleted.");
                    }
                  },
                  child: deleteButton(),
                ),
              )
            : DataCell(
                Text(
                  " ",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDarkTheme.value ? foregroundColor : backgroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ],
    );
  }

  @override
  int get rowCount => _tasks.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
