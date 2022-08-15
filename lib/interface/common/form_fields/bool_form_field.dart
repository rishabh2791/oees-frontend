import 'package:flutter/cupertino.dart';
import 'package:oees/interface/common/form_fields/bool_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';

class BoolFormField implements FormFielder {
  final String label;
  final String formField;
  bool isEnabled;
  TextEditingController selectedController;

  BoolFormField({
    required this.label,
    required this.formField,
    required this.selectedController,
    this.isEnabled = true,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      formField: selectedController.text,
    };
  }

  @override
  Widget render() {
    return BoolFieldWidget(
      label: label,
      formField: formField,
      selectedController: selectedController,
      isEnabled: isEnabled,
    );
  }

  @override
  bool validate() {
    return true;
  }

  @override
  void clear() {
    selectedController.text = "";
  }
}
