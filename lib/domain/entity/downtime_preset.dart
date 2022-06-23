class DowntimePreset {
  final String id;
  final String type;
  final int defaultPeriod;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool selected = false;

  DowntimePreset({
    required this.createdAt,
    required this.defaultPeriod,
    required this.description,
    required this.id,
    required this.type,
    required this.updatedAt,
  });

  @override
  String toString() {
    return description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "id": id,
      "default_period": defaultPeriod,
      "description": description,
      "type": type,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }

  factory DowntimePreset.fromJSON(Map<String, dynamic> jsonObject) {
    DowntimePreset downtimePreset = DowntimePreset(
      createdAt: DateTime.parse(jsonObject["created_at"]),
      defaultPeriod: int.parse(jsonObject["default_period"].toString()),
      description: jsonObject["description"],
      id: jsonObject["id"],
      type: jsonObject["type"],
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
    );
    return downtimePreset;
  }
}

class DowntimeTypes {
  final String id;
  final String description;

  DowntimeTypes({
    required this.description,
    required this.id,
  });

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "id": id,
      "description": description,
    };
  }

  @override
  String toString() {
    return description;
  }
}

List<DowntimeTypes> downtimeTypes = [
  DowntimeTypes(description: "Planned", id: "Planned"),
  DowntimeTypes(description: "Unplanned", id: "Unplanned"),
  DowntimeTypes(description: "Controlled", id: "Controlled"),
];
