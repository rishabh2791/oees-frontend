import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/shift.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/bool_form_field.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/lists/task_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class TaskListWidget extends StatefulWidget {
  const TaskListWidget({Key? key}) : super(key: key);

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  bool isLoading = true;
  bool isPlantLoaded = false;
  bool isDataLoaded = false;
  List<Line> lines = [];
  List<Shift> shifts = [];
  List<Task> tasks = [], filteredTasks = [];
  Map<String, dynamic> map = {};
  late BoolFormField onlyIncompleteFormField;
  late DropdownFormField lineFormField, shiftFormField;
  late TextEditingController lineController, shiftController, onlyIncompleteController;
  late FormFieldWidget formFieldWidget;

  @override
  void initState() {
    lineController = TextEditingController();
    shiftController = TextEditingController();
    onlyIncompleteController = TextEditingController();
    lineController.addListener(filterTasks);
    shiftController.addListener(filterTasks);
    onlyIncompleteController.addListener(filterTasks);
    getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getLines() async {
    await appStore.lineApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Line line = Line.fromJSON(item);
          lines.add(line);
        }
      } else {
        setState(() {
          errorMessage = "Unable to get Lines.";
          isError = true;
        });
      }
    });
    lines.sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> getShifts() async {
    await appStore.shiftApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Shift shift = Shift.fromJSON(item);
          shifts.add(shift);
        }
      } else {
        setState(() {
          errorMessage = "Unable to get Shifts.";
          isError = true;
        });
      }
    });
    shifts.sort((a, b) => a.description.compareTo(b.description));
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
      isPlantLoaded = true;
    });
    await Future.forEach([await getLines(), await getShifts()], (element) {
      if (errorMessage.isEmpty && errorMessage == "") {
        initForm();
      }
    }).then((value) async {
      tasks = [];
      await appStore.taskApp.list({}).then((response) {
        if (response.containsKey("status") && response["status"]) {
          for (var item in response["payload"]) {
            Task task = Task.fromJSON(item);
            tasks.add(task);
          }
          filteredTasks = tasks;
          filteredTasks.sort((a, b) => a.line.name.compareTo(b.line.name));
          setState(() {
            isDataLoaded = true;
          });
        } else {
          if (response.containsKey("status")) {
            setState(() {
              errorMessage = response["message"];
              isError = true;
            });
          } else {
            setState(() {
              errorMessage = "Unable to get Devices";
              isError = true;
            });
          }
        }
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  void initForm() {
    lineFormField = DropdownFormField(
      formField: "line_id",
      controller: lineController,
      dropdownItems: lines,
      hint: "Select Line",
    );
    shiftFormField = DropdownFormField(
      formField: "shift_id",
      controller: shiftController,
      dropdownItems: shifts,
      hint: "Select Shift",
    );
    onlyIncompleteFormField = BoolFormField(
      label: "Show Only Incomplete",
      formField: "only_complete",
      selectedController: onlyIncompleteController,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        lineFormField,
        shiftFormField,
        onlyIncompleteFormField,
      ],
    );
  }

  void filterTasks() {
    filteredTasks = tasks;
    if (onlyIncompleteController.text == "1") {
      filteredTasks.removeWhere((element) => element.complete);
    }
    if (lineController.text.isNotEmpty) {
      filteredTasks = filteredTasks.where((element) => element.line.id == lineController.text).toList();
    }
    if (shiftController.text.isNotEmpty) {
      filteredTasks = filteredTasks.where((element) => element.shift.id == shiftController.text).toList();
    }
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
            : SuperWidget(
                childWidget: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tasks",
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
                      isDataLoaded ? formFieldWidget.render("horizontal") : Container(),
                      isDataLoaded
                          ? tasks.isNotEmpty
                              ? TaskList(tasks: filteredTasks)
                              : Text(
                                  "No Tasks Found",
                                  style: TextStyle(
                                    color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                          : Container(),
                    ],
                  ),
                ),
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
