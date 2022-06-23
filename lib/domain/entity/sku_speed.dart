import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/domain/entity/user.dart';

class SKUSpeed {
  final String id;
  final Line line;
  final SKU sku;
  final double speed;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;
  bool selected = false;

  SKUSpeed({
    required this.createdAt,
    required this.createdBy,
    required this.id,
    required this.line,
    required this.sku,
    required this.speed,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return line.name + " - " + sku.description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "id": id,
      "line": line.toJSON(),
      "sku": sku.toJSON(),
      "speed": speed,
      "created_by": createdBy.toJSON(),
      "created_at": createdAt,
      "updated_by": updatedBy.toJSON(),
      "updated_at": updatedAt,
    };
  }

  factory SKUSpeed.fromJSON(Map<String, dynamic> jsonObject) {
    SKUSpeed skuSpeed = SKUSpeed(
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      id: jsonObject["id"],
      line: Line.fromJSON(jsonObject["line"]),
      sku: SKU.fromJSON(jsonObject["sku"]),
      speed: double.parse(jsonObject["speed"].toString()),
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
    );
    return skuSpeed;
  }
}
