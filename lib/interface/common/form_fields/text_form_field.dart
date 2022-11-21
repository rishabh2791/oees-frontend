import 'package:flutter/cupertino.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/text_field.dart';

class TextFormFielder implements FormFielder {
  final String formField;
  final bool obscureText;
  final TextEditingController controller;
  final String label;
  bool disabled;
  final bool isRequired;
  final int minSize;
  final int maxSize;
  bool isValid;

  TextFormFielder({
    required this.controller,
    this.disabled = false,
    required this.formField,
    this.isRequired = true,
    required this.label,
    this.obscureText = false,
    this.maxSize = 0,
    this.minSize = 0,
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
    return TextFieldWidget(
      controller: controller,
      disabled: disabled,
      label: label,
      obscureText: obscureText,
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
    if (maxSize != 0 && controller.text.length > maxSize) {
      errorMessage += "\u2022 " +
          label +
          " can not be more than " +
          maxSize.toString() +
          " long.\n";
      isValid = false;
      return false;
    }
    if (minSize != 0 && controller.text.length < minSize) {
      errorMessage += "\u2022 " +
          label +
          " can not be less than " +
          minSize.toString() +
          " long.\n";
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
