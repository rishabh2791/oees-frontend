import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/downtime_preset/downtime_preset_create_widget.dart';
import 'package:oees/interface/downtime_preset/downtime_preset_list_widget.dart';

class DowntimePresetWidget extends StatefulWidget {
  const DowntimePresetWidget({Key? key}) : super(key: key);

  @override
  State<DowntimePresetWidget> createState() => _DowntimePresetWidgetState();
}

class _DowntimePresetWidgetState extends State<DowntimePresetWidget> {
  @override
  Widget build(BuildContext context) {
    return SuperWidget(
      childWidget: BaseWidget(
        builder: (context, screenSizeInfo) {
          return SizedBox(
            height: screenSizeInfo.screenSize.height,
            width: screenSizeInfo.screenSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserActionButton(
                      accessType: "create",
                      callback: () {
                        navigationService.pushReplacement(
                          CupertinoPageRoute(
                            builder: (BuildContext context) => const DowntimePresetCreateWidget(),
                          ),
                        );
                      },
                      icon: Icons.create,
                      label: "Create",
                      table: "preset_downtimes",
                    ),
                    UserActionButton(
                      accessType: "view",
                      callback: () {
                        navigationService.pushReplacement(
                          CupertinoPageRoute(
                            builder: (BuildContext context) => const DowntimePresetListWidget(),
                          ),
                        );
                      },
                      icon: Icons.list_alt,
                      label: "List",
                      table: "preset_downtimes",
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
      errorCallback: () {
        setState(
          () {
            isError = false;
            errorMessage = "";
          },
        );
      },
    );
  }
}
