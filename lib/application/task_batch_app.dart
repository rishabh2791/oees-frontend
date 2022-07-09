import 'package:oees/domain/repository/task_batch_repository.dart';

abstract class TaskBatchAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> task);
  Future<Map<String, dynamic>> list(String taskID);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> task);
}

class TaskBatchApp implements TaskBatchAppInterface {
  final TaskBatchRepository taskBatchRepository;

  TaskBatchApp({required this.taskBatchRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> task) async {
    return taskBatchRepository.create(task);
  }

  @override
  Future<Map<String, dynamic>> list(String taskID) async {
    return taskBatchRepository.list(taskID);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> task) async {
    return taskBatchRepository.update(id, task);
  }
}
