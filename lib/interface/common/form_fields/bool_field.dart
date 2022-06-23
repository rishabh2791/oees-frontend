import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';

class BoolFieldWidget extends StatefulWidget {
  final String label;
  final String formField;
  final TextEditingController selectedController;
  const BoolFieldWidget({
    Key? key,
    required this.formField,
    required this.label,
    required this.selectedController,
  }) : super(key: key);

  @override
  State<BoolFieldWidget> createState() => _BoolFieldWidgetState();
}

class _BoolFieldWidgetState extends State<BoolFieldWidget> {
  @override
  void initState() {
    widget.selectedController.text = "0";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 60.0,
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
          child: Transform.scale(
            scale: 2.0,
            child: Checkbox(
              value: widget.selectedController.text == "1" ? true : false,
              fillColor: MaterialStateProperty.all(isDarkTheme.value ? foregroundColor : backgroundColor),
              activeColor: isDarkTheme.value ? foregroundColor : backgroundColor,
              onChanged: (bool? value) {
                setState(() {
                  widget.selectedController.text = value! ? "1" : "0";
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
            widget.label,
            style: TextStyle(
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
