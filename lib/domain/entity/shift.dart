import 'package:oees/domain/entity/plant.dart';
import 'package:oees/domain/entity/user.dart';

class Shift {
  final String id;
  final Plant plant;
  final String code;
  final String description;
  final String startTime;
  final String endTime;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;
  bool selected = false;

  Shift({
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.description,
    required this.endTime,
    required this.id,
    required this.plant,
    required this.startTime,
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
      "description": description,
      "end_time": endTime,
      "id": id,
      "plant": plant.toJSON(),
      "start_time": startTime,
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  factory Shift.fromJSON(Map<String, dynamic> jsonObject) {
    Shift shift = Shift(
      code: jsonObject["code"],
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      description: jsonObject["description"],
      endTime: jsonObject["end_time"],
      id: jsonObject["id"],
      plant: Plant.fromJSON(jsonObject["plant"]),
      startTime: jsonObject["start_time"],
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
    );
    return shift;
  }
}
