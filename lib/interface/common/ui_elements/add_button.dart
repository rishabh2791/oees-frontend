import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';

Widget addButton() {
  return Tooltip(
    decoration: BoxDecoration(
      color: isDarkTheme.value ? foregroundColor : backgroundColor,
    ),
    message: "Add New",
    child: const Padding(
      padding: EdgeInsets.all(10.0),
      child: Icon(
        Icons.add,
        color: backgroundColor,
        size: 30.0,
      ),
    ),
  );
}
