abstract class DowntimePresetRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> downtimePreset);
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> downtimePreset);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
}
