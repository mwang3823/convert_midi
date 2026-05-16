import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:flutter/material.dart';
import '../../common/theme.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool autoSize;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.autoSize = false,
  });

  @override
  Widget build(BuildContext context) {
    final ts = style ?? AppTextStyle.regular();
    if (autoSize) {
      return AutoSizeText(
        text,
        style: ts,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.ellipsis,
        textAlign: textAlign,
      );
    }
    return Text(
      text,
      style: ts,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
