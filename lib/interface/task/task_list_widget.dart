import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/lists/task_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

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
  List<Task> tasks = [];
  Map<String, dynamic> map = {};
  late DropdownFormField lineFormField;
  late TextEditingController lineController;
  late FormFieldWidget lineFormFieldWidget;

  @override
  void initState() {
    lineController = TextEditingController();
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
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
      isPlantLoaded = true;
    });
    await Future.forEach([await getLines()], (element) {
      if (errorMessage.isEmpty && errorMessage == "") {
        initForm();
      }
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
    lineFormFieldWidget = FormFieldWidget(
      formFields: [
        lineFormField,
      ],
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
                      isDataLoaded ? Container() : lineFormFieldWidget.render(),
                      isDataLoaded
                          ? tasks.isNotEmpty
                              ? TaskList(tasks: tasks)
                              : Text(
                                  "No Tasks Found",
                                  style: TextStyle(
                                    color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                          : Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: MaterialButton(
                                    onPressed: () async {
                                      Map<String, dynamic> lineConditions = {};
                                      map = lineFormFieldWidget.toJSON();
                                      if (lineController.text.isNotEmpty) {
                                        lineConditions = {
                                          "EQUALS": {
                                            "Field": "line_id",
                                            "Value": map["line_id"],
                                          }
                                        };
                                      } else {
                                        List<String> lineIDs = [];
                                        for (var line in lines) {
                                          lineIDs.add(line.id);
                                        }
                                        lineConditions = {
                                          "IN": {
                                            "Field": "line_id",
                                            "Value": lineIDs,
                                          }
                                        };
                                      }
                                      tasks = [];
                                      await appStore.taskApp.list(lineConditions).then((response) {
                                        if (response.containsKey("status") && response["status"]) {
                                          for (var item in response["payload"]) {
                                            Task task = Task.fromJSON(item);
                                            tasks.add(task);
                                          }
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
                                          builder: (BuildContext context) => const TaskListWidget(),
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
