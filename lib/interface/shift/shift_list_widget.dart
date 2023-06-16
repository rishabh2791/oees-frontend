import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/shift.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/lists/shift_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class ShiftListWidget extends StatefulWidget {
  const ShiftListWidget({Key? key}) : super(key: key);

  @override
  State<ShiftListWidget> createState() => _ShiftListWidgetState();
}

class _ShiftListWidgetState extends State<ShiftListWidget> {
  bool isLoading = true;
  bool isShiftsLoaded = false;
  List<Shift> shifts = [];
  Map<String, dynamic> map = {};
  late FormFieldWidget formFieldWidget;

  @override
  void initState() {
    getShifts();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getShifts() async {
    setState(() {
      isLoading = true;
    });
    shifts = [];
    await appStore.shiftApp.list({}).then((response) async {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Shift shift = await Shift.fromJSON(item);
          shifts.add(shift);
        }
        setState(() {
          isLoading = false;
          isShiftsLoaded = true;
        });
      } else {
        setState(() {
          errorMessage = "Unable to get Lines.";
          isError = true;
        });
      }
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
                : Container();
      },
    );
  }
}
