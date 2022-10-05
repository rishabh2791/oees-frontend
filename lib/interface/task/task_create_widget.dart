import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/job.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/shift.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/date_form_field.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/file_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';
import 'package:flutter/foundation.dart' as foundation;

class TaskCreateWidget extends StatefulWidget {
  const TaskCreateWidget({Key? key}) : super(key: key);

  @override
  State<TaskCreateWidget> createState() => _TaskCreateWidgetState();
}

class _TaskCreateWidgetState extends State<TaskCreateWidget> {
  bool isLoading = true;
  bool isDataLoaded = false;
  List<Line> lines = [];
  List<Job> jobs = [];
  List<Shift> shifts = [];
  late Map<String, dynamic> map;
  late FileFormField fileFormField;
  late FormFieldWidget formFieldWidget;
  late FilePickerResult? file;
  late DropdownFormField lineFormField, shiftFormField;
  late TextFormFielder jobCodeFormField;
  late DateFormField dateFormField;
  late TextEditingController fileFieldControlled,
      jobCodeController,
      dateController,
      shiftController,
      lineController;

  @override
  void initState() {
    getData();
    fileFieldControlled = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getFile(FilePickerResult? result) {
    setState(() {
      file = result;
      fileFieldControlled.text = result!.files.single.name;
    });
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

  Future<void> getJobs() async {
    await appStore.jobApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Job job = Job.fromJSON(item);
          jobs.add(job);
        }
      } else {
        setState(() {
          errorMessage = "Unable to get Jobs.";
          isError = true;
        });
      }
    });
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
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    await Future.forEach([await getLines(), await getJobs(), await getShifts()],
        (element) {
      if (errorMessage.isEmpty && errorMessage == "") {
        fileFormField = FileFormField(
          fileController: fileFieldControlled,
          formField: "file",
          hint: "Select File",
          label: "Select File",
          updateParent: getFile,
        );
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
    jobCodeController = TextEditingController();
    dateController = TextEditingController();
    shiftController = TextEditingController();
    lineController = TextEditingController();
    jobCodeFormField = TextFormFielder(
      controller: jobCodeController,
      formField: "job_code",
      label: "Job Code",
    );
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
      jobCodeFormField,
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
                  backgroundColor:
                      isDarkTheme.value ? foregroundColor : backgroundColor,
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                ),
              )
            : SuperWidget(
                childWidget: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Tasks",
                        style: TextStyle(
                          color: isDarkTheme.value
                              ? foregroundColor
                              : backgroundColor,
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
                                  map = formFieldWidget.toJSON();
                                  map["created_by_username"] =
                                      currentUser.username;
                                  map["updated_by_username"] =
                                      currentUser.username;
                                  String jobCode = map["job_code"];
                                  Job job = jobs.firstWhere(
                                      (element) => element.code == jobCode);
                                  map["job_id"] = job.id;
                                  map.remove("job_code");
                                  map["scheduled_date"] =
                                      map["scheduled_date"] + "T00:00:00.0Z";
                                  map["plan"] = job.plan;
                                  await appStore.taskApp
                                      .create(map)
                                      .then((response) {
                                    if (response.containsKey("status") &&
                                        response["status"]) {
                                      setState(() {
                                        errorMessage = "Tasks Created";
                                        isError = true;
                                      });
                                      fileFormField.clear();
                                      navigationService.pushReplacement(
                                        CupertinoPageRoute(
                                          builder: (BuildContext context) =>
                                              const TaskCreateWidget(),
                                        ),
                                      );
                                    } else {
                                      if (response.containsKey("status")) {
                                        String message = response["message"]
                                                .toString()
                                                .contains("Duplicate")
                                            ? "Task Already Created."
                                            : response["message"];
                                        setState(() {
                                          errorMessage = message;
                                          isError = true;
                                        });
                                      } else {
                                        setState(() {
                                          errorMessage =
                                              "Unbale to Create Task.";
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
                                    builder: (BuildContext context) =>
                                        const TaskCreateWidget(),
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
                      const Divider(
                        color: Colors.transparent,
                        height: 50.0,
                      ),
                      Text(
                        "-- OR --",
                        style: TextStyle(
                          color: isDarkTheme.value
                              ? foregroundColor
                              : backgroundColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(
                        color: Colors.transparent,
                        height: 50.0,
                      ),
                      SizedBox(
                        width: 400,
                        child: fileFormField.render(),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              onPressed: () async {
                                if (jobs.isEmpty ||
                                    lines.isEmpty ||
                                    shifts.isEmpty) {
                                  setState(() {
                                    isError = true;
                                    errorMessage =
                                        "Unable to Create Tasks at this time.";
                                  });
                                } else {
                                  List<Map<String, dynamic>> tasks = [];
                                  // ignore: prefer_typing_uninitialized_variables
                                  var csvData;
                                  if (foundation.kIsWeb) {
                                    final bytes =
                                        utf8.decode(file!.files.single.bytes!);
                                    csvData = const CsvToListConverter()
                                        .convert(bytes);
                                  } else {
                                    final csvFile =
                                        File(file!.files.single.path.toString())
                                            .openRead();
                                    csvData = await csvFile
                                        .transform(utf8.decoder)
                                        .transform(
                                          const CsvToListConverter(),
                                        )
                                        .toList();
                                  }
                                  setState(() {
                                    isLoading = true;
                                  });
                                  csvData.forEach((line) {
                                    late DateTime scheduledDate;
                                    try {
                                      scheduledDate = DateTime.parse(line[2]);
                                    } catch (e) {
                                      String date =
                                          line[2].toString().substring(0, 2);
                                      String month =
                                          line[2].toString().substring(3, 5);
                                      String year =
                                          line[2].toString().substring(6, 10);
                                      scheduledDate = DateTime(int.parse(year),
                                          int.parse(month), int.parse(date));
                                    }
                                    Job job = jobs.firstWhere((element) =>
                                        element.code.toString() ==
                                        line[0].toString());
                                    String lineID = lines
                                        .firstWhere((element) =>
                                            element.code == line[1])
                                        .id;
                                    String shiftID = shifts
                                        .firstWhere((element) =>
                                            element.code == line[3])
                                        .id;
                                    Map<String, dynamic> task = {
                                      "job_id": job.id,
                                      "line_id": lineID,
                                      "scheduled_date": scheduledDate
                                              .toString()
                                              .substring(0, 10) +
                                          "T00:00:00.0Z",
                                      "shift_id": shiftID,
                                      "plan": job.plan,
                                      "created_by_username":
                                          currentUser.username,
                                      "updated_by_username":
                                          currentUser.username,
                                    };
                                    tasks.add(task);
                                  });
                                  await appStore.taskApp
                                      .createMultiple(tasks)
                                      .then((response) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (response.containsKey("status") &&
                                        response["status"]) {
                                      setState(() {
                                        errorMessage = "Tasks Created";
                                        isError = true;
                                      });
                                      fileFormField.clear();
                                    } else {
                                      if (response.containsKey("status")) {
                                        setState(() {
                                          errorMessage = response["message"];
                                          isError = true;
                                        });
                                      } else {
                                        setState(() {
                                          errorMessage =
                                              "Unbale to Create Tasks.";
                                          isError = true;
                                        });
                                      }
                                    }
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
                                    builder: (BuildContext context) =>
                                        const TaskCreateWidget(),
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
