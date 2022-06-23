import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/time_picker.dart';

class TimeFormField implements FormFielder {
  final TextEditingController controller;
  final String formField, hint, label;
  final bool isRequired;
  bool enabled;
  bool isValid;

  TimeFormField({
    required this.controller,
    required this.formField,
    required this.hint,
    this.isRequired = true,
    required this.label,
    this.enabled = true,
    this.isValid = true,
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
    return TimePickerWidget(
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
    isValid = true;
    return true;
  }

  @override
  void clear() {
    controller.text = "";
  }
}
