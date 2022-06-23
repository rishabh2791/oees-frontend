import 'package:oees/domain/repository/shift_repository.dart';

class ShiftApp implements ShiftAppInterface {
  final ShiftRepository shiftRepository;
  ShiftApp({required this.shiftRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> shift) async {
    return shiftRepository.create(shift);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> shifts) async {
    return shiftRepository.createMultiple(shifts);
  }

  @override
  Future<Map<String, dynamic>> getShift(String id) async {
    return shiftRepository.getShift(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return shiftRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> shift) async {
    return shiftRepository.update(id, shift);
  }
}

abstract class ShiftAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> shift);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> shifts);
  Future<Map<String, dynamic>> getShift(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> shift);
}
