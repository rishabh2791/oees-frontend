abstract class TaskRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> taks);
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> tasks);
  Future<Map<String, dynamic>> getTask(String id);
  Future<Map<String, dynamic>> getLastTask(String lineID, String taskID);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> task);
  Future<Map<String, dynamic>> delete(String id);
}
