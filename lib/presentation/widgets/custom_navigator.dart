import 'package:flutter/material.dart';

class CustomNavigator {
  static Future<T?> push<T>(BuildContext context, Widget screen) =>
      Navigator.push<T>(
          context, MaterialPageRoute<T>(builder: (_) => screen));

  static Future<T?> pushReplacement<T, TO>(
          BuildContext context, Widget screen) =>
      Navigator.pushReplacement<T, TO>(
          context, MaterialPageRoute<T>(builder: (_) => screen));

  static void pop<T>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);
}
