import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/services/navigation_service.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/dropdown_form_field.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/form_fields/int_form_field.dart';
import 'package:oees/interface/common/form_fields/text_form_field.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';
import 'package:oees/interface/common/ui_elements/check_button.dart';
import 'package:oees/interface/common/ui_elements/clear_button.dart';

class JobCreateWidget extends StatefulWidget {
  const JobCreateWidget({Key? key}) : super(key: key);

  @override
  State<JobCreateWidget> createState() => _JobCreateWidgetState();
}

class _JobCreateWidgetState extends State<JobCreateWidget> {
  bool isLoading = true;
  List<SKU> skus = [];
  late Map<String, dynamic> map;
  late FormFieldWidget formFieldWidget;
  late DropdownFormField skuFormField;
  late TextFormFielder jobCodeFormField;
  late IntFormFielder planFormField;
  late TextEditingController jobCodeController, skuController, planController;

  @override
  void initState() {
    getMaterials();
    jobCodeController = TextEditingController();
    skuController = TextEditingController();
    planController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getMaterials() async {
    skus = [];
    await appStore.skuApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          SKU sku = SKU.fromJSON(item);
          skus.add(sku);
        }
      } else {
        setState(() {
          errorMessage = "Unable to get Lines.";
          isError = true;
        });
      }
      initForm();
      setState(() {
        isLoading = false;
      });
    });
    skus.sort(((a, b) => a.code.compareTo(b.code)));
  }

  void initForm() {
    skuFormField = DropdownFormField(
      formField: "sku_id",
      controller: skuController,
      dropdownItems: skus,
      hint: "Select SKU",
    );
    jobCodeFormField = TextFormFielder(
      controller: jobCodeController,
      formField: "code",
      label: "Job Code",
      isRequired: true,
    );
    planFormField = IntFormFielder(
      controller: planController,
      formField: "plan",
      label: "Plan",
      isRequired: true,
      min: 1,
    );
    formFieldWidget = FormFieldWidget(
      formFields: [
        jobCodeFormField,
        skuFormField,
        planFormField,
      ],
    );
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
                childWidget: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Jobs",
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
                      formFieldWidget.render(),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              onPressed: () async {
                                if (formFieldWidget.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  map = formFieldWidget.toJSON();
                                  map["created_by_username"] = currentUser.username;
                                  map["updated_by_username"] = currentUser.username;
                                  map["sku"] = {};
                                  map["sku"]["code"] = skus.firstWhere((element) => element.id == map["sku_id"]).code.toString();
                                  map.remove("sku_id");
                                  await appStore.jobApp.create(map).then((response) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (response.containsKey("status") && response["status"]) {
                                      setState(() {
                                        errorMessage = "Jobs Created";
                                        isError = true;
                                      });
                                      navigationService.pushReplacement(
                                        CupertinoPageRoute(
                                          builder: (BuildContext context) => const JobCreateWidget(),
                                        ),
                                      );
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
                                } else {
                                  setState(() {
                                    isError = true;
                                  });
                                }
                              },
                              color: foregroundColor,
                              height: 60.0,
                              minWidth: 50.0,
                              child: checkButton(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              onPressed: () {
                                navigationService.pushReplacement(
                                  CupertinoPageRoute(
                                    builder: (BuildContext context) => const JobCreateWidget(),
                                  ),
                                );
                              },
                              color: foregroundColor,
                              height: 60.0,
                              minWidth: 50.0,
                              child: clearButton(),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.transparent,
                        height: 50.0,
                      ),
                      Center(
                        child: Text(
                          "-or-",
                          style: TextStyle(
                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.transparent,
                        height: 50.0,
                      ),
                      TextButton(
                        onPressed: () async {
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
                        child: Text(
                          "Pull From Syspro",
                          style: TextStyle(
                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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
      },
    );
  }
}
