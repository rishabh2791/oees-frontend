import 'package:oees/domain/entity/plant.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/domain/entity/user.dart';

class Job {
  final String id;
  final String code;
  final Plant plant;
  final SKU sku;
  final int plan;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;

  Job({
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.id,
    required this.plan,
    required this.plant,
    required this.sku,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return code + "-" + plant.description + "-" + sku.description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "code": code,
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "id": id,
      "plan": plan,
      "plant": plant.toJSON(),
      "sku": sku.toJSON(),
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  factory Job.fromJSON(Map<String, dynamic> jsonObject) {
    Job job = Job(
      code: jsonObject["code"],
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      id: jsonObject["id"],
      plan: int.parse(jsonObject["plan"].toString()),
      plant: Plant.fromJSON(jsonObject["plant"]),
      sku: SKU.fromJSON(jsonObject["sku"]),
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
    );
    return job;
  }
}
