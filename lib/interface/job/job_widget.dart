import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/job/job_create_widget.dart';
import 'package:oees/interface/job/job_list_widget.dart';

class JobWidget extends StatefulWidget {
  const JobWidget({Key? key}) : super(key: key);

  @override
  State<JobWidget> createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidget> {
  bool isLoading = true;

  @override
  void initState() {
    setState(() {
      isLoading = false;
    });
    super.initState();
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
                                        builder: (BuildContext context) => const JobCreateWidget(),
                                      ),
                                    );
                                  },
                                  icon: Icons.create,
                                  label: "Create Job",
                                  table: "jobs",
                                ),
                                UserActionButton(
                                  accessType: "create",
                                  callback: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await appStore.jobApp.pullFromSyspro().then((response) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (response.containsKey("status") && response["status"]) {
                                        setState(() {
                                          errorMessage = "Jobs Created";
                                          isError = true;
                                        });
                                      } else {
                                        if (response.containsKey("status")) {
                                          setState(() {
                                            errorMessage = response["message"];
                                            isError = true;
                                          });
                                        } else {
                                          setState(() {
                                            errorMessage = "Unbale to Create Jobs.";
                                            isError = true;
                                          });
                                        }
                                      }
                                    });
                                  },
                                  icon: Icons.create,
                                  label: "Pull Jobs",
                                  table: "jobs",
                                ),
                                UserActionButton(
                                  accessType: "view",
                                  callback: () {
                                    navigationService.pushReplacement(
                                      CupertinoPageRoute(
                                        builder: (BuildContext context) => const JobListWidget(),
                                      ),
                                    );
                                  },
                                  icon: Icons.list_alt,
                                  label: "List Jobs",
                                  table: "jobs",
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
        });
  }
}
