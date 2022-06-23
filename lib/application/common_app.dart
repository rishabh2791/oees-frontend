import 'package:oees/domain/repository/common_repository.dart';

class CommonApp implements CommonAppInterface {
  final CommonRepository commonRepository;

  CommonApp({required this.commonRepository});
  @override
  Future<Map<String, dynamic>> getTables() async {
    return commonRepository.getTables();
  }
}

abstract class CommonAppInterface {
  Future<Map<String, dynamic>> getTables();
}
