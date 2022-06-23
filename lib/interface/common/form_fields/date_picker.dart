import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/screen_size_information.dart';

// ignore: must_be_immutable
class DatePickerWidget extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController dateController;
  final Map<String, DateTime> range;
  bool enabled;

  bool isValid;

  DatePickerWidget({
    Key? key,
    required this.dateController,
    required this.hintText,
    required this.labelText,
    this.isValid = true,
    this.enabled = true,
    this.range = const {},
  }) : super(key: key);

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime currentDate = DateTime.now();

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        widget.dateController.text = pickedDate.toString().substring(0, 10);
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
