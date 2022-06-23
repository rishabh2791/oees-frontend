import 'package:oees/domain/entity/device.dart';

class DeviceData {
  final String id;
  final Device device;
  final double value;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceData({
    required this.createdAt,
    required this.device,
    required this.id,
    required this.updatedAt,
    required this.value,
  });

  @override
  String toString() {
    return device.description + " - " + value.toString();
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "id": id,
      "device": device.toJSON(),
      "value": value,
      "created_at": createdAt,
      "updated_by": updatedAt,
    };
  }

  factory DeviceData.fromJSON(Map<String, dynamic> jsonObject) {
    DeviceData deviceData = DeviceData(
      createdAt: DateTime.parse(jsonObject["created_at"]),
      device: Device.fromJSON(jsonObject["device"]),
      id: jsonObject["id"],
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      value: double.parse(jsonObject["value"].toString()),
    );
    return deviceData;
  }
}
