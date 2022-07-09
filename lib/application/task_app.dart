import 'package:oees/domain/repository/task_repository.dart';

class TaskApp implements TaskAppInterface {
  final TaskRepository taskRepository;
  TaskApp({required this.taskRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> task) async {
    return taskRepository.create(task);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> tasks) async {
    return taskRepository.createMultiple(tasks);
  }

  @override
  Future<Map<String, dynamic>> getTask(String id) async {
    return taskRepository.getTask(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return taskRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> task) async {
    return taskRepository.update(id, task);
  }
}

abstract class TaskAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> task);
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> tasks);
  Future<Map<String, dynamic>> getTask(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> task);
}
