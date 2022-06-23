import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/screen_size_information.dart';

// ignore: must_be_immutable
class FilePickerWidget extends StatefulWidget {
  final TextEditingController fileController;
  final String label, hint;
  final Function(FilePickerResult? result) updateParent;
  final List<String> allowedExtensions;
  bool isValid;

  FilePickerWidget({
    Key? key,
    required this.fileController,
    required this.hint,
    required this.label,
    required this.updateParent,
    this.isValid = true,
    this.allowedExtensions = const ['csv'],
  }) : super(key: key);

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  Widget filePickerField(ScreenSizeInformation sizeInfo, String labelText, hintText, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      width: sizeInfo.localWidgetSize.width,
      decoration: BoxDecoration(
        color: widget.isValid ? Colors.white : Colors.pink,
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
      child: TextFormField(
        readOnly: true,
        obscureText: false,
        controller: widget.fileController,
        style: TextStyle(
          color: isDarkTheme.value ? lightThemeFormLabelTextColor : darkThemeFormLabelTextColor,
          fontWeight: FontWeight.bold,
        ),
        onTap: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: widget.allowedExtensions,
          );

          if (result != null) {
            widget.updateParent(result);
          }
        },
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          labelStyle: TextStyle(
            color: isDarkTheme.value ? lightThemeFormLabelTextColor : darkThemeFormLabelTextColor,
            fontWeight: FontWeight.bold,
          ),
          hintStyle: TextStyle(
            color: isDarkTheme.value ? darkThemeFormLabelTextColor : lightThemeFormLabelTextColor,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: isDarkTheme.value ? darkThemeFormLabelTextColor : lightThemeFormLabelTextColor,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      builder: (context, size) {
        return filePickerField(
          size,
          widget.label,
          widget.hint,
          widget.fileController,
        );
      },
    );
  }
}
