import 'package:oees/domain/repository/common_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class CommonRepo implements CommonRepository {
  @override
  Future<Map<String, dynamic>> getTables() async {
    String url = "common/tables/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }
}
