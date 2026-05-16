import 'package:flutter/material.dart';
import '../data/network/api/api.dart';
import 'interaction/interaction.dart';

class Repository {
  static Future login(BuildContext context, Map<String, dynamic> param) =>
      Interaction(context: context, url: API.login(), param: param).post();

  static Future logout(BuildContext context) =>
      Interaction(context: context, url: API.logout(), param: {}).post();
}
