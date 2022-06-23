import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/plant/plant_create_widget.dart';
import 'package:oees/interface/plant/plant_list_widget.dart';

class PlantWidget extends StatefulWidget {
  const PlantWidget({Key? key}) : super(key: key);

  @override
  State<PlantWidget> createState() => _PlantWidgetState();
}

class _PlantWidgetState extends State<PlantWidget> {
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
                            builder: (BuildContext context) => const PlantCreateWidget(),
                          ),
                        );
                      },
                      icon: Icons.create,
                      label: "Create Plant",
                      table: "plants",
                    ),
                    UserActionButton(
                      accessType: "view",
                      callback: () {
                        navigationService.pushReplacement(
                          CupertinoPageRoute(
                            builder: (BuildContext context) => const PlantListWidget(),
                          ),
                        );
                      },
                      icon: Icons.list_alt,
                      label: "List Plant",
                      table: "plants",
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
