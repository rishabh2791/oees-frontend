import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/int_field.dart';

class IntFormFielder implements FormFielder {
  final String formField;
  final TextEditingController controller;
  final String label;
  final bool disabled;
  final bool isRequired;
  final int min;
  final int max;
  bool isValid;

  IntFormFielder({
    required this.controller,
    this.disabled = false,
    required this.formField,
    this.isRequired = true,
    required this.label,
    this.max = 0,
    this.min = 0,
    this.isValid = true,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      formField: int.parse(controller.text),
    };
  }

  @override
  Widget render() {
    return IntFieldWidget(
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
    if (max != 0 && int.parse(controller.text.toString()) > max) {
      errorMessage += "\u2022 " + label + " can not be more than " + max.toString() + " long.\n";
      isValid = false;
      return false;
    }
    if (min != 0 && int.parse(controller.text.toString()) < min) {
      errorMessage += "\u2022 " + label + " can not be less than " + min.toString() + " long.\n";
      isValid = false;
      return false;
    }
    isValid = true;
    return true;
  }

  @override
  void clear() {
    controller.clear();
  }
}
