import 'package:flutter/material.dart';

abstract class FormFielder {
  Map<String, dynamic> toJSON();
  Widget render();
  bool validate();
  void clear();
}

class FormFieldWidget implements FormFielder {
  final List<FormFielder> formFields;
  final double? width;

  FormFieldWidget({
    required this.formFields,
    this.width = 500,
  });

  @override
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> map = {};
    for (var formField in formFields) {
      map.addAll(formField.toJSON());
    }
    return map;
  }

  @override
  Widget render([String direction = "vertical"]) {
    List<Widget> fields = [];
    for (var formField in formFields) {
      fields.add(
        SizedBox(
          width: width,
          child: formField.render(),
        ),
      );
    }
    return SizedBox(
      child: direction == "horizontal"
          ? Wrap(
              direction: Axis.horizontal,
              children: fields,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields,
            ),
    );
  }

  @override
  bool validate() {
    bool valid = true;
    for (var formField in formFields) {
      bool thisValid = formField.validate();
      valid = valid && thisValid;
    }
    return valid;
  }

  @override
  void clear() {
    for (var formField in formFields) {
      formField.clear();
    }
  }
}
