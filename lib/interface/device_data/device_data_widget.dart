import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/device.dart';
import 'package:oees/domain/entity/device_data.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/date_form_field.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class DeviceDataWidget extends StatefulWidget {
  const DeviceDataWidget({Key? key}) : super(key: key);

  @override
  State<DeviceDataWidget> createState() => _DeviceDataWidgetState();
}

class _DeviceDataWidgetState extends State<DeviceDataWidget> {
  bool isLoading = true;
  bool isLineSelected = false;
  List<Line> lines = [];
  List<DeviceData> deviceDatas = [];
  List<FlSpot> spots = [];
  late Map<String, dynamic> map;
  late FormFieldWidget formFieldWidget;
  late DropdownFormField lineFormField;
  late DateFormField startDateFormWidget, endDataFormWidget;
  late TextEditingController startDateController, endDateController, lineController;

  @override
  void initState() {
    getLines();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    lineController = TextEditingController();
    super.initState();
  }

  Future<void> getLines() async {
    lines = [];
    await appStore.lineApp.list({}).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Line line = await Line.fromJSON(item);
          lines.add(line);
        }
      }
      initForm();
      setState(() {
        isLoading = false;
      });
    });
  }

  void initForm() {
    startDateFormWidget = DateFormField(
      controller: startDateController,
      formField: "start_date",
      hint: "Start Date",
      label: "Start Date",
    );
    endDataFormWidget = DateFormField(
      controller: endDateController,
      formField: "end_date",
      hint: "End Date",
      label: "End Date",
    );
    lineFormField = DropdownFormField(
      formField: "line_id",
      controller: lineController,
      dropdownItems: lines,
      hint: "Select Line",
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        lineFormField,
        startDateFormWidget,
        endDataFormWidget,
      ],
    );
  }

  Widget selectionWidget() {
    Widget widget = Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "View Device Data",
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
                      map["use_for_oee"] = true;
                      map["end_date"] = DateTime.parse(map["end_date"]).add(const Duration(days: 1)).toString().substring(0, 10);
                      Map<String, dynamic> filters = {
                        "AND": [
                          {
                            "EQUALS": {
                              "Field": "line_id",
                              "Value": map["line_id"],
                            },
                          },
                          {
                            "EQUALS": {
                              "Field": "use_for_oee",
                              "Value": "1",
                            },
                          },
                        ],
                      };
                      await appStore.deviceApp.list(filters).then((response) async {
                        if (response.containsKey("status") && response["status"]) {
                          Device device = await Device.fromJSON(response["payload"][0]);
                          Map<String, dynamic> conditions = {
                            "AND": [
                              {
                                "EQUALS": {
                                  "Field": "device_id",
                                  "Value": device.id,
                                },
                              },
                              {
                                "BETWEEN": {
                                  "Field": "created_at",
                                  "HigherValue": DateTime.parse(map["end_date"]).toUtc().toString(),
                                  "LowerValue": DateTime.parse(map["start_date"]).toUtc().toString(),
                                }
                              },
                            ],
                          };
                          await appStore.deviceDataApp.list(conditions).then((value) async {
                            if (value.containsKey("status") && value["status"]) {
                              for (var item in value["payload"]) {
                                DeviceData deviceData = await DeviceData.fromJSON(item);
                                deviceDatas.add(deviceData);
                              }
                              deviceDatas.sort(((a, b) => a.createdAt.compareTo(b.createdAt)));
                              for (var deviceData in deviceDatas) {
                                spots.add(FlSpot(deviceData.createdAt.millisecondsSinceEpoch.toDouble(), deviceData.value));
                              }
                              setState(() {
                                isLoading = false;
                                isLineSelected = true;
                              });
                            } else {
                              setState(() {
                                isLoading = false;
                                errorMessage = "Unable to get Counter Data for Line.";
                                isError = true;
                              });
                            }
                          });
                        } else {
                          setState(() {
                            isLoading = false;
                            errorMessage = "Device Not Found for Line.";
                            isError = true;
                          });
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
                        builder: (BuildContext context) => const DeviceDataWidget(),
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
    );
    return widget;
  }

  Widget displayWidget() {
    Widget widget = Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Line: ",
                style: TextStyle(
                  fontSize: 20.0,
                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                ),
              ),
              Text(
                lines.firstWhere((element) => element.id == map["line_id"]).name,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                ),
              ),
              const VerticalDivider(
                width: 20,
                color: Colors.transparent,
              ),
              Text(
                "Start Date: ",
                style: TextStyle(
                  fontSize: 20.0,
                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                ),
              ),
              Text(
                map["start_date"],
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                ),
              ),
              const VerticalDivider(
                width: 20,
                color: Colors.transparent,
              ),
              Text(
                "End Date: ",
                style: TextStyle(
                  fontSize: 20.0,
                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                ),
              ),
              Text(
                DateTime.parse(map["end_date"]).subtract(const Duration(days: 1)).toString().substring(0, 10),
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                ),
              ),
            ],
          ),
          const Divider(
            height: 20,
            color: Colors.transparent,
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 200,
              child: AspectRatio(
                aspectRatio: 2,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        dotData: FlDotData(
                          show: false,
                        ),
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                      ),
                    ],
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 300,
                          interval: (DateTime.parse(map["end_date"]).millisecondsSinceEpoch.toDouble() - DateTime.parse(map["start_date"]).millisecondsSinceEpoch.toDouble()) / 40,
                          getTitlesWidget: ((value, meta) {
                            return RotatedBox(
                              quarterTurns: 1,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  DateTime.fromMillisecondsSinceEpoch(value.toInt()).toString().substring(0, 16),
                                  style: TextStyle(
                                    color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: ((value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return widget;
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
                childWidget: isLineSelected ? displayWidget() : selectionWidget(),
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
