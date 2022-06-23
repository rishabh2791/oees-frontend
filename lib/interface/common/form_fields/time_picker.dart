import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/screen_size_information.dart';

// ignore: must_be_immutable
class TimePickerWidget extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController dateController;
  final Map<String, DateTime> range;
  bool enabled;

  bool isValid;

  TimePickerWidget({
    Key? key,
    required this.dateController,
    required this.hintText,
    required this.labelText,
    this.isValid = true,
    this.enabled = true,
    this.range = const {},
  }) : super(key: key);

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  DateTime currentDate = DateTime.now();

  Future<void> _selectDate(TextEditingController controller) async {
    TimeOfDay now = TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
    final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: now);
    if (pickedTime != null && pickedTime != now) {
      setState(() {
        widget.dateController.text = pickedTime.toString();
      });
    }
  }

  Widget _dateWidget(ScreenSizeInformation sizeInfo, String labelText, hintText, TextEditingController controller) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(10.0),
          width: sizeInfo.localWidgetSize.width - 20,
          decoration: BoxDecoration(
            color: widget.isValid ? Colors.white : Colors.pink,
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 0),
                blurRadius: 1,
                color: isDarkTheme.value ? foregroundColor : backgroundColor,
              ),
            ],
          ),
          child: TextFormField(
            enabled: widget.enabled,
            readOnly: true,
            obscureText: false,
            controller: controller,
            style: TextStyle(
              color: isDarkTheme.value ? lightThemeFormLabelTextColor : darkThemeFormLabelTextColor,
              fontWeight: FontWeight.bold,
            ),
            onTap: () async {
              _selectDate(widget.dateController);
            },
            decoration: InputDecoration(
              fillColor: isDarkTheme.value ? backgroundColor : foregroundColor,
              labelText: labelText,
              hintText: hintText,
              labelStyle: TextStyle(
                color: isDarkTheme.value ? lightThemeFormLabelTextColor : darkThemeFormLabelTextColor,
                fontWeight: FontWeight.bold,
              ),
              hintStyle: TextStyle(
                color: isDarkTheme.value ? darkThemeFormLabelTextColor : lightThemeFormLabelTextColor,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: isDarkTheme.value ? darkThemeFormLabelTextColor : lightThemeFormLabelTextColor,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.red,
                ),
              ),
              suffixIcon: Icon(
                Icons.calendar_view_month,
                color: isDarkTheme.value ? lightThemeFormLabelTextColor : darkThemeFormLabelTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      builder: (context, sizeInfo) {
        return _dateWidget(sizeInfo, widget.labelText, widget.hintText, widget.dateController);
      },
    );
  }
}
