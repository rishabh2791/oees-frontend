import 'package:oees/domain/repository/job_repository.dart';

class JobApp implements JobAppInterface {
  final JobRepository jobRepository;

  JobApp({required this.jobRepository});
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> job) async {
    return jobRepository.create(job);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> jobs) async {
    return jobRepository.createMultiple(jobs);
  }

  @override
  Future<Map<String, dynamic>> getLine(String id) async {
    return jobRepository.getLine(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return jobRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> pullFromSyspro() async {
    return jobRepository.pullFromSyspro();
  }
}

abstract class JobAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> job);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> jobs);
  Future<Map<String, dynamic>> getLine(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> pullFromSyspro();
}
