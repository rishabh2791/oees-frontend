import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/sku_speed/sku_speed_create_widget.dart';
import 'package:oees/interface/sku_speed/sku_speed_list_widget.dart';

class SKUSpeedWidget extends StatefulWidget {
  const SKUSpeedWidget({Key? key}) : super(key: key);

  @override
  State<SKUSpeedWidget> createState() => _SKUSpeedWidgetState();
}

class _SKUSpeedWidgetState extends State<SKUSpeedWidget> {
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
                            builder: (BuildContext context) => const SKUSpeedCreateWidget(),
                          ),
                        );
                      },
                      icon: Icons.create,
                      label: "Create SKU",
                      table: "sku_speeds",
                    ),
                    UserActionButton(
                      accessType: "view",
                      callback: () {
                        navigationService.pushReplacement(
                          CupertinoPageRoute(
                            builder: (BuildContext context) => const SKUSpeedListWidget(),
                          ),
                        );
                      },
                      icon: Icons.list_alt,
                      label: "List SKUs",
                      table: "sku_speeds",
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
