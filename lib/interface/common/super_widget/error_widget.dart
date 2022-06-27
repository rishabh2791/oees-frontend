import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class ErrorDisplayWidget extends StatefulWidget {
  final Function callback;
  const ErrorDisplayWidget({
    Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  State<ErrorDisplayWidget> createState() => _ErrorDisplayWidgetState();
}

class _ErrorDisplayWidgetState extends State<ErrorDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10.0,
        sigmaY: 10.0,
      ),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 400,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Divider(
              height: 10.0,
              color: Colors.transparent,
            ),
            MaterialButton(
              onPressed: () {
                widget.callback();
              },
              color: Colors.green,
              height: 60.0,
              minWidth: 50.0,
              child: clearButton(),
            ),
          ],
        ),
      ),
    );
  }
}
