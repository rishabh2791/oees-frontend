abstract class AuthRepository {
  Future<Map<String, dynamic>> login(Map<String, dynamic> loginDetails);
  Future<Map<String, dynamic>> logout();
  Future<Map<String, dynamic>> refresh();
  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> passwordDetails);
}
