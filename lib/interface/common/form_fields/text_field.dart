import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

// ignore: must_be_immutable
class TextFieldWidget extends StatefulWidget {
  final bool obscureText;
  final TextEditingController controller;
  final String label;
  final bool disabled;
  bool isValid;

  TextFieldWidget({
    Key? key,
    required this.controller,
    required this.disabled,
    required this.label,
    required this.obscureText,
    this.isValid = true,
  }) : super(key: key);

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      builder: (context, size) {
        return Container(
          margin: const EdgeInsets.all(10.0),
          width: size.localWidgetSize.width,
          decoration: BoxDecoration(
            color: widget.disabled
                ? foregroundColor
                : widget.isValid
                    ? Colors.white
                    : Colors.pink,
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
            obscureText: widget.obscureText,
            controller: widget.controller,
            style: TextStyle(
              color: isDarkTheme.value ? lightThemeFormLabelTextColor : darkThemeFormLabelTextColor,
              fontWeight: FontWeight.bold,
            ),
            readOnly: widget.disabled,
            decoration: InputDecoration(
              fillColor: isDarkTheme.value ? backgroundColor : foregroundColor,
              labelText: widget.label,
              hintText: widget.label,
              labelStyle: TextStyle(
                color: isDarkTheme.value ? lightThemeFormLabelTextColor : darkThemeFormLabelTextColor,
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
            ),
          ),
        );
      },
    );
  }
}
