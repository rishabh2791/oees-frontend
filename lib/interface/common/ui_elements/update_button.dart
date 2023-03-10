import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';

Widget updateButton() {
  return const Tooltip(
    decoration: BoxDecoration(
      color: backgroundColor,
    ),
    message: "Update",
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Icon(
        Icons.upgrade,
        color: foregroundColor,
        size: 30.0,
      ),
    ),
  );
}
