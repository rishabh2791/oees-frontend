import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/downtime/downtime_create_widget.dart';
import 'package:oees/interface/downtime/job_downtime_list_widget.dart';
import 'package:oees/interface/downtime/line_downtime_list_widget.dart';

class DowntimeWidget extends StatefulWidget {
  const DowntimeWidget({Key? key}) : super(key: key);

  @override
  State<DowntimeWidget> createState() => _DowntimeWidgetState();
}

class _DowntimeWidgetState extends State<DowntimeWidget> {
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
                            builder: (BuildContext context) =>
                                const DowntimeCreateWidget(),
                          ),
                        );
                      },
                      icon: Icons.create,
                      label: "Create",
                      table: "downtimes",
                    ),
                    // UserActionButton(
                    //   accessType: "update",
                    //   callback: () {
                    //     navigationService.pushReplacement(
                    //       CupertinoPageRoute(
                    //         builder: (BuildContext context) => const DowntimeUpdateWidget(),
                    //       ),
                    //     );
                    //   },
                    //   icon: Icons.list_alt,
                    //   label: "Update",
                    //   table: "downtimes",
                    // ),
                    UserActionButton(
                      accessType: "view",
                      callback: () {
                        navigationService.pushReplacement(
                          CupertinoPageRoute(
                            builder: (BuildContext context) =>
                                const DowntimeListWidget(),
                          ),
                        );
                      },
                      icon: Icons.list_alt,
                      label: "List by Job",
                      table: "downtimes",
                    ),
                    UserActionButton(
                      accessType: "view",
                      callback: () {
                        navigationService.pushReplacement(
                          CupertinoPageRoute(
                            builder: (BuildContext context) =>
                                const LineDowntimeListWidget(),
                          ),
                        );
                      },
                      icon: Icons.list_alt,
                      label: "List by Line",
                      table: "downtimes",
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
