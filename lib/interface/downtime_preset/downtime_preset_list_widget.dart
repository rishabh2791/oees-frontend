import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/downtime_preset.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/lists/downtime_preset_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class DowntimePresetListWidget extends StatefulWidget {
  const DowntimePresetListWidget({Key? key}) : super(key: key);

  @override
  State<DowntimePresetListWidget> createState() =>
      _DowntimePresetListWidgetState();
}

class _DowntimePresetListWidgetState extends State<DowntimePresetListWidget> {
  bool isLoading = true;
  List<DowntimePreset> presets = [];

  @override
  void initState() {
    getPresets();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getPresets() async {
    presets = [];
    await appStore.downtimePresetApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          DowntimePreset downtimePreset = DowntimePreset.fromJSON(item);
          presets.add(downtimePreset);
        }
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
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
                  backgroundColor:
                      isDarkTheme.value ? foregroundColor : backgroundColor,
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                ),
              )
            : SuperWidget(
                childWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Preset Downtime",
                      style: TextStyle(
                        color: isDarkTheme.value
                            ? foregroundColor
                            : backgroundColor,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 50.0,
                    ),
                    presets.isEmpty
                        ? Text(
                            "No Presets Found",
                            style: TextStyle(
                              color: isDarkTheme.value
                                  ? foregroundColor
                                  : backgroundColor,
                              fontSize: 30.0,
                            ),
                          )
                        : DowntimePresetList(presets: presets),
                  ],
                ),
                errorCallback: () {
                  setState(() {
                    isError = false;
                    errorMessage = "";
                  });
                },
              );
      },
    );
  }
}
