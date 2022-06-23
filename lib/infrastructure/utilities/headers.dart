import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/variables.dart';

Map<String, String> getHeader(TokenType tokenType) {
  String? token = tokenType == TokenType.accessToken ? storage?.getString("access_token") : storage?.getString("refresh_token");

  Map<String, String> header = {"Content-Type": "application/text"};
  if (tokenType != TokenType.none) {
    header["Authorization"] = tokenType.toString() + " " + token.toString();
  }
  return header;
}
