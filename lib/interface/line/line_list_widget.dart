import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/lists/line_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class LineListWidget extends StatefulWidget {
  const LineListWidget({Key? key}) : super(key: key);

  @override
  State<LineListWidget> createState() => _LineListWidgetState();
}

class _LineListWidgetState extends State<LineListWidget> {
  bool isLoading = true;
  bool isLinesLoaded = false;
  List<Line> lines = [];
  Map<String, dynamic> map = {};
  late FormFieldWidget formFieldWidget;

  @override
  void initState() {
    getLines();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getLines() async {
    setState(() {
      isLoading = true;
    });
    await appStore.lineApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Line line = Line.fromJSON(item);
          lines.add(line);
        }
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Unable to get Lines.";
          isError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkTheme,
      builder: (context, darkTheme, child) {
        return isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                ),
              )
            : SuperWidget(
                childWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "All Lines",
                      style: TextStyle(
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 50.0,
                    ),
                    lines.isNotEmpty
                        ? LineList(lines: lines)
                        : Text(
                            "No Lines Found",
                            style: TextStyle(
                              color: isDarkTheme.value ? foregroundColor : backgroundColor,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
                ),
                errorCallback: () {},
              );
      },
    );
  }
}
