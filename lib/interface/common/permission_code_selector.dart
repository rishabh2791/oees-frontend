import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';

class PermissionCodeSelector extends StatefulWidget {
  final String title;
  final TextEditingController codeController;
  const PermissionCodeSelector({
    Key? key,
    required this.title,
    required this.codeController,
  }) : super(key: key);

  @override
  _PermissionCodeSelectorState createState() => _PermissionCodeSelectorState();
}

class _PermissionCodeSelectorState extends State<PermissionCodeSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      height: 60.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 400,
              child: Text(
                widget.title.toUpperCase().replaceAll("_", " "),
                style: TextStyle(
                  color: isDarkTheme.value ? foregroundColor : backgroundColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              width: 200,
              child: Row(
                children: [
                  Container(
                    height: 60.0,
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    child: Transform.scale(
                      scale: 2.0,
                      child: Checkbox(
                        value: widget.codeController.text[0] == "1" ? true : false,
                        fillColor: MaterialStateProperty.all(isDarkTheme.value ? foregroundColor : foregroundColor),
                        activeColor: isDarkTheme.value ? backgroundColor : foregroundColor,
                        onChanged: (bool? value) {
                          setState(() {
                            var createState = value! ? "1" : "0";
                            widget.codeController.text =
                                createState + widget.codeController.text[1] + widget.codeController.text[2] + widget.codeController.text[3];
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Text(
                      "Create",
                      style: TextStyle(
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              width: 200,
              child: Row(
                children: [
                  Container(
                    height: 60.0,
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    child: Transform.scale(
                      scale: 2.0,
                      child: Checkbox(
                        value: widget.codeController.text[1] == "1" ? true : false,
                        fillColor: MaterialStateProperty.all(isDarkTheme.value ? foregroundColor : foregroundColor),
                        activeColor: isDarkTheme.value ? backgroundColor : foregroundColor,
                        onChanged: (bool? value) {
                          setState(() {
                            var readState = value! ? "1" : "0";
                            widget.codeController.text =
                                widget.codeController.text[0] + readState + widget.codeController.text[2] + widget.codeController.text[3];
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Text(
                      "Read",
                      style: TextStyle(
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              width: 200,
              child: Row(
                children: [
                  Container(
                    height: 60.0,
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    child: Transform.scale(
                      scale: 2.0,
                      child: Checkbox(
                        value: widget.codeController.text[2] == "1" ? true : false,
                        fillColor: MaterialStateProperty.all(isDarkTheme.value ? foregroundColor : foregroundColor),
                        activeColor: isDarkTheme.value ? backgroundColor : foregroundColor,
                        onChanged: (bool? value) {
                          setState(() {
                            var updateState = value! ? "1" : "0";
                            widget.codeController.text =
                                widget.codeController.text[0] + widget.codeController.text[1] + updateState + widget.codeController.text[3];
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Text(
                      "Update",
                      style: TextStyle(
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              width: 200,
              child: Row(
                children: [
                  Container(
                    height: 60.0,
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    child: Transform.scale(
                      scale: 2.0,
                      child: Checkbox(
                        value: widget.codeController.text[3] == "1" ? true : false,
                        fillColor: MaterialStateProperty.all(isDarkTheme.value ? foregroundColor : foregroundColor),
                        activeColor: isDarkTheme.value ? backgroundColor : foregroundColor,
                        onChanged: (bool? value) {
                          setState(() {
                            var deleteState = value! ? "1" : "0";
                            widget.codeController.text =
                                widget.codeController.text[0] + widget.codeController.text[1] + widget.codeController.text[2] + deleteState;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Text(
                      "Delete",
                      style: TextStyle(
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
