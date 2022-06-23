import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/double_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';

class DoubleFormFielder implements FormFielder {
  final String formField;
  final TextEditingController controller;
  final String label;
  final bool disabled;
  final bool isRequired;
  final double min;
  final double max;
  bool isValid;

  DoubleFormFielder({
    required this.controller,
    this.disabled = false,
    required this.formField,
    this.isRequired = true,
    required this.label,
    this.max = 0.0,
    this.min = 0.0,
    this.isValid = true,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      formField: controller.text,
    };
  }

  @override
  Widget render() {
    return DoubleFieldWidget(
      controller: controller,
      disabled: disabled,
      label: label,
      isValid: isValid,
    );
  }

  @override
  bool validate() {
    if (isRequired && (controller.text.isEmpty || controller.text == "")) {
      errorMessage += "\u2022 " + label + " required.\n";
      isValid = false;
      return false;
    }
    if (max != 0 && double.parse(controller.text.toString()) > max) {
      errorMessage += "\u2022 " + label + " can not be more than " + max.toString() + " long.\n";
      isValid = false;
      return false;
    }
    if (min != 0 && double.parse(controller.text.toString()) < min) {
      errorMessage += "\u2022 " + label + " can not be less than " + min.toString() + " long.\n";
      isValid = false;
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
