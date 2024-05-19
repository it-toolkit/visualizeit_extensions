


import 'package:flutter/widgets.dart';

final _customAlignmentRegExp = RegExp(r'^-?(1(\.0)?|0(\.[0-9]+)?)/-?(1(\.0)?|0(\.[0-9]+)?)$');

Alignment parseAlignment(String alignment) {

  if(_customAlignmentRegExp.hasMatch(alignment)) {
    final alignmentParts = alignment.split("/");
    return Alignment(double.parse(alignmentParts[0]), double.parse(alignmentParts[1]));
  }

  switch(alignment) {
    case "topLeft": return Alignment.topLeft;
    case "topCenter": return Alignment.topCenter;
    case "topRight": return Alignment.topRight;
    case "centerLeft": return Alignment.centerLeft;
    case "center": return Alignment.center;
    case "centerRight": return Alignment.centerRight;
    case "bottomLeft": return Alignment.bottomLeft;
    case "bottomCenter": return Alignment.bottomCenter;
    case "bottomRight": return Alignment.bottomRight;
    default: throw Exception("Unknown alignment value"); //TODO handle error properly
  }
}