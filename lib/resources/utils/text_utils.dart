import "package:flutter/material.dart";

double getTextHeight({required final String text, required final TextStyle style}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1
  );

  textPainter.layout();
  return textPainter.size.height;
}

double getTextWidth({required final String text, required final TextStyle style}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1
  );

  textPainter.layout();
  return textPainter.size.width;
}
