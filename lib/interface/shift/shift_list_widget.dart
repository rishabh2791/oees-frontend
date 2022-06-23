import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/plant.dart';
import 'package:oees/domain/entity/shift.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/lists/shift_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class ShiftListWidget extends StatefulWidget {
  const ShiftListWidget({Key? key}) : super(key: key);

  @override
  State<ShiftListWidget> createState() => _ShiftListWidgetState();
}

class _ShiftListWidgetState extends State<ShiftListWidget> {
  bool isLoading = true;
  bool isShiftsLoaded = false;
  List<Plant> plants = [];
  List<Shift> shifts = [];
  Map<String, dynamic> map = {};
  late FormFieldWidget formFieldWidget;
  late DropdownFormField plantFormField;
  late TextEditingController plantController;

  @override
  void initState() {
    getPlants();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initForm() {
    plantController = TextEditingController();
    plantFormField = DropdownFormField(
      formField: "plant_code",
      controller: plantController,
      dropdownItems: plants,
      hint: "Select Plant",
      primaryKey: "code",
      isRequired: true,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        plantFormField,
      ],
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getPlants() async {
    plants = [];
    await appStore.plantApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Plant plant = Plant.fromJSON(item);
          plants.add(plant);
        }
      } else {
        setState(() {
          errorMessage = response["message"];
          isError = true;
        });
      }
    }).then((value) {
      initForm();
    });
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
            : isShiftsLoaded
                ? SuperWidget(
                    childWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All Shifts",
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
                        shifts.isNotEmpty
                            ? ShiftList(shifts: shifts)
                            : Text(
                                "No SHifts Found",
                                style: TextStyle(
                                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                    errorCallback: () {},
                  )
                : SuperWidget(
                    childWidget: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "List Shifts",
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
                                    map = formFieldWidget.toJSON();
                                    Map<String, dynamic> conditions = {};
                                    if (map["plant_code"].isNotEmpty) {
                                      conditions = {
                                        "EQUALS": {
                                          "Field": "plant_code",
                                          "Value": map["plant_code"],
                                        }
                                      };
                                    }
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await appStore.shiftApp.list(conditions).then((response) {
                                      if (response.containsKey("status") && response["status"]) {
                                        for (var item in response["payload"]) {
                                          Shift shift = Shift.fromJSON(item);
                                          shifts.add(shift);
                                        }
                                        setState(() {
                                          isLoading = false;
                                          isShiftsLoaded = true;
                                        });
                                      } else {
                                        if (response.containsKey("status")) {
                                          setState(() {
                                            errorMessage = response["message"];
                                            isError = true;
                                            isLoading = false;
                                          });
                                        } else {
                                          setState(() {
                                            errorMessage = "Unable to Get Shifts";
                                            isError = true;
                                            isLoading = false;
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
                                        builder: (BuildContext context) => const ShiftListWidget(),
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
