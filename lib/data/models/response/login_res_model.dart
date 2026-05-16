class LoginResModel {
  String? token;
  String? refreshToken;

  LoginResModel({this.token, this.refreshToken});

  LoginResModel.fromJson(Map<String, dynamic> json) {
    token        = json['token'] as String?;
    refreshToken = json['refresh_token'] as String?;
  }
}
