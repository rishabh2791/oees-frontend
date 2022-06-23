import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/plant.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/lists/plant_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class PlantListWidget extends StatefulWidget {
  const PlantListWidget({Key? key}) : super(key: key);

  @override
  State<PlantListWidget> createState() => _PlantListWidgetState();
}

class _PlantListWidgetState extends State<PlantListWidget> {
  bool isLoading = true;
  List<Plant> plants = [];

  @override
  void initState() {
    getPlants();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getPlants() async {
    plants = [];
    await appStore.plantApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Plant plant = Plant.fromJSON(item);
          plants.add(plant);
        }
      } else {
        setState(() {
          errorMessage = response["message"];
          isError = true;
        });
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
                  backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                ),
              )
            : SuperWidget(
                childWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "List Plant",
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
                    plants.isNotEmpty
                        ? PlantList(plants: plants)
                        : Text(
                            "No Plants Found",
                            style: TextStyle(
                              color: isDarkTheme.value ? foregroundColor : backgroundColor,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
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
