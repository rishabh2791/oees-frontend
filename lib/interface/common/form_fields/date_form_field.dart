import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/date_picker.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';

class DateFormField implements FormFielder {
  final TextEditingController controller;
  final String formField, hint, label;
  final bool isRequired;
  Map<String, DateTime> range;
  bool isValid;
  bool enabled;

  DateFormField({
    required this.controller,
    required this.formField,
    required this.hint,
    this.isRequired = true,
    required this.label,
    this.isValid = true,
    this.enabled = true,
    this.range = const {},
  });

  @override
  Map<String, dynamic> toJSON() {
    if (controller.text.isEmpty || controller.text == "") {
      return {};
    }
    return <String, dynamic>{
      formField: controller.text.toString(),
    };
  }

  @override
  Widget render() {
    return DatePickerWidget(
      dateController: controller,
      hintText: hint,
      labelText: label,
      isValid: isValid,
      enabled: enabled,
    );
  }

  @override
  bool validate() {
    if (isRequired && (controller.text.isEmpty || controller.text == "")) {
      isValid = false;
      errorMessage += "\u2022 " + label + " required.\n";
      return false;
    }
    if (range.containsKey("start_date") && DateTime.parse(controller.text).difference(range["start_date"]!).inDays > 0) {
      isValid = false;
      errorMessage += "\u2022 " + label + " can not be befofe " + range["start_date"].toString().substring(0, 10) + "\n";
      return false;
    }
    if (range.containsKey("end_date") && DateTime.parse(controller.text).difference(range["end_date"]!).inDays < 0) {
      isValid = false;
      errorMessage += "\u2022 " + label + " can not be after " + range["end_date"].toString().substring(0, 10) + "\n";
      return false;
    }
    isValid = true;
    return true;
  }

  @override
  void clear() {
    controller.text = "";
  }
}
