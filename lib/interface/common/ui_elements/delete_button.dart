import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';

Widget deleteButton() {
  return const Tooltip(
    decoration: BoxDecoration(
      color: backgroundColor,
    ),
    message: "Delete",
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Icon(
        Icons.delete,
        color: foregroundColor,
        size: 30.0,
      ),
    ),
  );
}
