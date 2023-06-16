import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/user.dart';

class SKU {
  final String id;
  final String code;
  final String description;
  final int caseLot;
  final double minWeight;
  final double maxWeight;
  final double expectedWeight;
  final int lowRunSpeed;
  final int highRunSpeed;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;
  bool selected = false;

  SKU._({
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.id,
    required this.minWeight,
    required this.maxWeight,
    required this.expectedWeight,
    required this.lowRunSpeed,
    required this.highRunSpeed,
    required this.description,
    required this.caseLot,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return code.toString() + " - " + description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "code": code,
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "id": id,
      "min_weight": minWeight,
      "max_weight": maxWeight,
      "expected_weight": expectedWeight,
      "low_run_speed": lowRunSpeed,
      "high_run_speed": highRunSpeed,
      "description": description,
      "case_lot": caseLot,
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  static Future<SKU> fromJSON(Map<String, dynamic> jsonObject) async {
    late SKU sku;

    await appStore.userApp.getUser(jsonObject["created_by_username"]).then((createdByResponse) async {
      await appStore.userApp.getUser(jsonObject["updated_by_username"]).then((udpatedByResponse) async {
        sku = SKU._(
          code: jsonObject["code"],
          createdAt: DateTime.parse(jsonObject["created_at"]),
          createdBy: await User.fromJSON(createdByResponse["payload"]),
          id: jsonObject["id"],
          minWeight: double.parse(jsonObject["min_weight"].toString()),
          maxWeight: double.parse(jsonObject["max_weight"].toString()),
          expectedWeight: double.parse(jsonObject["expected_weight"].toString()),
          lowRunSpeed: int.parse(jsonObject["low_run_speed"].toString()),
          highRunSpeed: int.parse(jsonObject["high_run_speed"].toString()),
          description: jsonObject["description"],
          caseLot: jsonObject["case_lot"],
          updatedAt: DateTime.parse(jsonObject["updated_at"]),
          updatedBy: await User.fromJSON(udpatedByResponse["payload"]),
        );
      });
    });

    return sku;
  }
}
