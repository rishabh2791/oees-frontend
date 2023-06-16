import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/job.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/shift.dart';
import 'package:oees/domain/entity/task.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/date_form_field.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class TaskUpdateWidget extends StatefulWidget {
  final Task task;
  const TaskUpdateWidget({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskUpdateWidget> createState() => _TaskUpdateWidgetState();
}

class _TaskUpdateWidgetState extends State<TaskUpdateWidget> {
  bool isLoading = true;
  bool isDataLoaded = false;
  List<Line> lines = [];
  List<Job> jobs = [];
  List<Shift> shifts = [];
  late Map<String, dynamic> map;
  late FormFieldWidget formFieldWidget;
  late DropdownFormField lineFormField, shiftFormField;
  late DateFormField dateFormField;
  late TextEditingController dateController, shiftController, lineController;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getLines() async {
    await appStore.lineApp.list({}).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Line line = await Line.fromJSON(item);
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

  Future<void> getShifts() async {
    await appStore.shiftApp.list({}).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Shift shift = await Shift.fromJSON(item);
          shifts.add(shift);
        }
      } else {
        setState(() {
          errorMessage = "Unable to get Shifts.";
          isError = true;
        });
      }
    });
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    await Future.forEach([await getLines(), await getShifts()], (element) {
      if (errorMessage.isEmpty && errorMessage == "") {
        initForm();
        setState(() {
          isDataLoaded = true;
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  initForm() {
    dateController = TextEditingController();
    shiftController = TextEditingController();
    lineController = TextEditingController();
    dateController.text = widget.task.scheduledDate.toString().substring(0, 10);
    shiftController.text = widget.task.shift.id;
    lineController.text = widget.task.line.id;

    dateFormField = DateFormField(
      controller: dateController,
      formField: "scheduled_date",
      hint: "Scheduled Date",
      label: "Schedule Date",
    );
    shiftFormField = DropdownFormField(
      formField: "shift_id",
      controller: shiftController,
      dropdownItems: shifts,
      hint: "Shift",
    );
    lineFormField = DropdownFormField(
      formField: "line_id",
      controller: lineController,
      dropdownItems: lines,
      hint: "Line",
    );
    formFieldWidget = FormFieldWidget(formFields: [
      lineFormField,
      dateFormField,
      shiftFormField,
    ]);
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
            : Scaffold(
                backgroundColor: isDarkTheme.value ? backgroundColor : foregroundColor,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Update Task for Job Code " + widget.task.job.code,
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
                                        map["updated_by_username"] = currentUser.username;
                                        map["scheduled_date"] = map["scheduled_date"] + "T00:00:00.0Z";
                                        await appStore.taskApp.update(widget.task.id, map).then((response) {
                                          if (response.containsKey("status") && response["status"]) {
                                            setState(() {
                                              isLoading = false;
                                              errorMessage = "Tasks Updated";
                                              isError = true;
                                            });
                                            navigationService.pushReplacement(
                                              CupertinoPageRoute(
                                                builder: (BuildContext context) => TaskUpdateWidget(
                                                  task: widget.task,
                                                ),
                                              ),
                                            );
                                          } else {
                                            if (response.containsKey("status")) {
                                              setState(() {
                                                isLoading = false;
                                                errorMessage = response["message"];
                                                isError = true;
                                              });
                                            } else {
                                              setState(() {
                                                isLoading = false;
                                                errorMessage = "Unbale to Update Task.";
                                                isError = true;
                                              });
                                            }
                                          }
                                        });
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
                                          builder: (BuildContext context) => TaskUpdateWidget(
                                            task: widget.task,
                                          ),
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
                    ),
                  ],
                ));
      },
    );
  }
}
