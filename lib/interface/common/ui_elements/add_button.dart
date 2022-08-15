import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';

Widget addButton() {
  return const Tooltip(
    decoration: BoxDecoration(
      color: Colors.green,
    ),
    message: "Clear",
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Icon(
        Icons.add,
        color: backgroundColor,
        size: 30.0,
      ),
    ),
  );
}
