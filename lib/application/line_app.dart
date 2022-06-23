import 'package:oees/domain/repository/line_repository.dart';

class LineApp implements LineAppInterface {
  final LineRepository lineRepository;
  LineApp({required this.lineRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> line) async {
    return lineRepository.create(line);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> lines) async {
    return lineRepository.createMultiple(lines);
  }

  @override
  Future<Map<String, dynamic>> getLine(String id) async {
    return lineRepository.getLine(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return lineRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> line) async {
    return lineRepository.update(id, line);
  }
}

abstract class LineAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> line);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> lines);
  Future<Map<String, dynamic>> getLine(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> line);
}
