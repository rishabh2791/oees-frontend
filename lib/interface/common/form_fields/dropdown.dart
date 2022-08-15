import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

// ignore: must_be_immutable
class DropDownWidget extends StatefulWidget {
  final bool disabled;
  final String hint;
  final String initialValue;
  final List<dynamic> dropdownItems;
  final TextEditingController controller;
  final String primaryKey;
  bool isValid;

  DropDownWidget({
    Key? key,
    required this.controller,
    required this.disabled,
    required this.dropdownItems,
    required this.hint,
    this.initialValue = "",
    this.primaryKey = "id",
    this.isValid = true,
  }) : super(key: key);

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  late String _chosenValue;

  @override
  void initState() {
    _chosenValue = widget.initialValue;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DropdownMenuItem<String>> getMenuItems(List<dynamic> dropDownListItems) {
    List<DropdownMenuItem<String>> menuItem = [];
    menuItem.add(DropdownMenuItem<String>(
      value: "",
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
        child: Text(
          widget.hint,
          style: TextStyle(
            color: isDarkTheme.value ? backgroundColor : foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));
    for (var dropdownListItem in dropDownListItems) {
      DropdownMenuItem<String> newItem = DropdownMenuItem<String>(
        value: dropdownListItem.toJSON()[widget.primaryKey],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
          child: Text(
            dropdownListItem.toString(),
            style: TextStyle(
              color: isDarkTheme.value ? backgroundColor : foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      menuItem.add(newItem);
    }
    return menuItem;
  }

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
          child: DropdownButton<String>(
            value: _chosenValue,
            elevation: 10,
            icon: const Icon(Icons.expand_more),
            isExpanded: true,
            dropdownColor: isDarkTheme.value ? foregroundColor : backgroundColor,
            // menuMaxHeight: 300.0,
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.black,
            focusColor: Colors.white,
            items: getMenuItems(widget.dropdownItems),
            underline: Container(),
            onChanged: (value) {
              setState(() {
                _chosenValue = value.toString();
                widget.controller.text = value.toString();
              });
            },
            hint: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
              child: Text(
                widget.hint,
                style: TextStyle(
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
