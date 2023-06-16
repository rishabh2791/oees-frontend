import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/domain/entity/user.dart';

class Job {
  final String id;
  final String code;
  final SKU sku;
  final int plan;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;

  Job._({
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.id,
    required this.plan,
    required this.sku,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return code + "-" + sku.description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "code": code,
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "id": id,
      "plan": plan,
      "sku": sku.toJSON(),
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  static Future<Job> fromJSON(Map<String, dynamic> jsonObject) async {
    late Job job;

    await appStore.userApp.getUser(jsonObject["created_by_username"]).then((createdByResponse) async {
      await appStore.userApp.getUser(jsonObject["updated_by_username"]).then((udpatedByResponse) async {
        await appStore.skuApp.getSKU(jsonObject["sku_id"]).then((skuResponse) async {
          job = Job._(
            code: jsonObject["code"],
            createdAt: DateTime.parse(jsonObject["created_at"]),
            createdBy: await User.fromJSON(createdByResponse["payload"]),
            id: jsonObject["id"],
            plan: int.parse(jsonObject["plan"].toString()),
            sku: await SKU.fromJSON(skuResponse["payload"]),
            updatedAt: DateTime.parse(jsonObject["updated_at"]),
            updatedBy: await User.fromJSON(udpatedByResponse["payload"]),
          );
        });
      });
    });

    return job;
  }
}
