import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';

Widget clearButton() {
  return Tooltip(
    decoration: BoxDecoration(
      color: isDarkTheme.value ? foregroundColor : backgroundColor,
    ),
    message: "Clear",
    child: const Padding(
      padding: EdgeInsets.all(10.0),
      child: Icon(
        Icons.clear_all,
        color: backgroundColor,
        size: 30.0,
      ),
    ),
  );
}
