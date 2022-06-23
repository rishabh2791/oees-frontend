import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/file_picker.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';

class FileFormField implements FormFielder {
  final bool isRequired;
  final String formField;
  final String label;
  final String hint;
  final TextEditingController fileController;
  final List<String> allowedExtensions;
  final Function(FilePickerResult? result) updateParent;
  bool isValid;

  FileFormField({
    this.isRequired = true,
    required this.fileController,
    required this.formField,
    required this.hint,
    required this.label,
    required this.updateParent,
    this.allowedExtensions = const ['csv'],
    this.isValid = true,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{};
  }

  @override
  Widget render() {
    return FilePickerWidget(
      fileController: fileController,
      hint: hint,
      label: label,
      updateParent: updateParent,
      allowedExtensions: allowedExtensions,
      isValid: isValid,
    );
  }

  @override
  bool validate() {
    if (isRequired && (fileController.text == "" || fileController.text.isEmpty)) {
      errorMessage += "\u2022 " + label + " required.\n";
      isValid = false;
      return false;
    }
    isValid = true;
    return true;
  }

  @override
  void clear() {
    fileController.text = "";
  }
}
