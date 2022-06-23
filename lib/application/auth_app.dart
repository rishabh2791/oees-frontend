import 'package:oees/domain/repository/auth_repository.dart';

class AuthApp implements AuthAppInterface {
  final AuthRepository authRepository;
  AuthApp({required this.authRepository});

  @override
  Future<Map<String, dynamic>> login(Map<String, dynamic> loginDetails) async {
    return authRepository.login(loginDetails);
  }

  @override
  Future<Map<String, dynamic>> logout() async {
    return authRepository.logout();
  }

  @override
  Future<Map<String, dynamic>> refresh() async {
    return authRepository.refresh();
  }

  @override
  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> passwordDetails) async {
    return authRepository.resetPassword(passwordDetails);
  }
}

abstract class AuthAppInterface {
  Future<Map<String, dynamic>> login(Map<String, dynamic> loginDetails);
  Future<Map<String, dynamic>> logout();
  Future<Map<String, dynamic>> refresh();
  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> passwordDetails);
}
