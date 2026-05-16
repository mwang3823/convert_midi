import '../../../common/globals.dart';

class API {
  static String get server => Globals.config.server ?? '';
  static int    get successCode => 0;

  static String login()        => 'api/auth/sign-in';
  static String logout()       => 'api/auth/sign-out';
  static String refreshToken() => 'api/auth/refresh-token';
}
