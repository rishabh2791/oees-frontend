abstract class ShiftRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> shift);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> shifts);
  Future<Map<String, dynamic>> getShift(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> shift);
}
