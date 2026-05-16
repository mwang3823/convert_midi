import 'package:flutter/material.dart';

class AppColors {
  static const primary    = Color(0xFF184AB4);
  static const secondary  = Color(0xFF0171CC);
  static const accent     = Color(0xFFFD5E32);
  static const white      = Colors.white;
  static const black      = Colors.black;
  static const red        = Color(0xFFD70000);
  static const grey       = Color(0xFFB3B3B3);
  static const greyLight  = Color(0xFFE0E0E0);
  static const green      = Color(0xFF399D47);
  static const orange     = Color(0xFFF7941E);
  static const blue       = Color(0xFF00A1E4);
  static const background = Color(0xFFf4f4f4);
}

class AppSizes {
  static const double maxPadding   = 16.0;
  static const double minPadding   = 8.0;
  static const double borderRadius = 12.0;
}

class AppFonts {
  static const montserrat = 'Montserrat';
  static const roboto     = 'Roboto';
}

class AppTextStyle {
  static TextStyle bold({double size = 14, Color color = AppColors.black}) =>
      TextStyle(fontWeight: FontWeight.bold, fontSize: size, color: color);
  static TextStyle medium({double size = 14, Color color = AppColors.black}) =>
      TextStyle(fontWeight: FontWeight.w500, fontSize: size, color: color);
  static TextStyle regular({double size = 14, Color color = AppColors.black}) =>
      TextStyle(fontWeight: FontWeight.normal, fontSize: size, color: color);
}
