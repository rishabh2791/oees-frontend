import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/form_fields/form_field.dart';
import 'package:oees/interface/common/lists/sku_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class SKUListWidget extends StatefulWidget {
  const SKUListWidget({Key? key}) : super(key: key);

  @override
  State<SKUListWidget> createState() => _SKUListWidgetState();
}

class _SKUListWidgetState extends State<SKUListWidget> {
  bool isLoading = true;
  bool isSKUsLoaded = false;
  List<SKU> skus = [];
  Map<String, dynamic> map = {};
  late FormFieldWidget formFieldWidget;

  @override
  void initState() {
    getSKUs();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getSKUs() async {
    skus = [];
    await appStore.skuApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          SKU sku = SKU.fromJSON(item);
          skus.add(sku);
        }
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response["message"];
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
                      "All SKUs",
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
                    skus.isNotEmpty
                        ? SKUList(skus: skus)
                        : Text(
                            "No SKUs Found",
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
