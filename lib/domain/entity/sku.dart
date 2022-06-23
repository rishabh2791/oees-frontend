import 'package:oees/domain/entity/plant.dart';
import 'package:oees/domain/entity/user.dart';

class SKU {
  final String id;
  final Plant plant;
  final String code;
  final String description;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;
  bool selected = false;

  SKU({
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.id,
    required this.description,
    required this.plant,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "code": code,
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "id": id,
      "description": description,
      "plant": plant.toJSON(),
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  factory SKU.fromJSON(Map<String, dynamic> jsonObject) {
    SKU line = SKU(
      code: jsonObject["code"],
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      id: jsonObject["id"],
      description: jsonObject["description"],
      plant: Plant.fromJSON(jsonObject["plant"]),
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
    );
    return line;
  }
}
