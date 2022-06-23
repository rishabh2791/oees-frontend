import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';

class DropdownFormField implements FormFielder {
  final String formField;
  final String hint;
  TextEditingController controller;
  final bool disabled;
  List<dynamic> dropdownItems;
  final bool isRequired;
  final String primaryKey;
  bool isValid;

  DropdownFormField({
    required this.formField,
    required this.controller,
    this.disabled = false,
    required this.dropdownItems,
    required this.hint,
    this.primaryKey = "id",
    this.isRequired = true,
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
    return DropDownWidget(
      controller: controller,
      disabled: disabled,
      dropdownItems: dropdownItems,
      hint: hint,
      isValid: isValid,
      primaryKey: primaryKey,
    );
  }

  @override
  bool validate() {
    if (isRequired && (controller.text.isEmpty || controller.text == "")) {
      errorMessage += "\u2022 " + hint + " required.\n";
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
