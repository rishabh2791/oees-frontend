abstract class TaskBatchRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> task);
  Future<Map<String, dynamic>> list(String taskID);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> task);
}
