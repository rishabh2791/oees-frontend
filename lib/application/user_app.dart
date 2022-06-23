import 'package:oees/domain/repository/user_repository.dart';

class UserApp implements UserAppInterface {
  final UserRepository userRepository;
  UserApp({required this.userRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> user) async {
    return userRepository.create(user);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> users) async {
    return userRepository.createMultiple(users);
  }

  @override
  Future<Map<String, dynamic>> getUser(String username) async {
    return userRepository.getUser(username);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return userRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> user) async {
    return userRepository.update(id, user);
  }
}

abstract class UserAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> user);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> users);
  Future<Map<String, dynamic>> getUser(String username);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String username, Map<String, dynamic> user);
}
