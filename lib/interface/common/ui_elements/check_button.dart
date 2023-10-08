import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';

Widget checkButton() {
  return Tooltip(
    decoration: BoxDecoration(
      color: isDarkTheme.value ? foregroundColor : backgroundColor,
    ),
    message: "Check",
    child: const Padding(
      padding: EdgeInsets.all(10.0),
      child: Icon(
        Icons.check,
        color: backgroundColor,
        size: 30.0,
      ),
    ),
  );
}
