

import 'package:flutter/widgets.dart';
import 'package:visualizeit_extensions/scripting.dart';

extension CommandDefinitionIntExtensions on CommandDefinition {

  int getIntArgInRange({required String name, required RawCommand from, required int min, required int max}) {
    int value = getArg(name: name, from: from);
    if (value < min || value > max) throw Exception("'$name' must be in range [ $min , $max ]");

    return value;
  }

  int getIntArgGreaterOrEqualThan({required String name, required RawCommand from, required int min}) {
    int value = getArg(name: name, from: from);
    if (value < min) throw Exception("'$name' must be greater than or equal to '$min'");

    return value;
  }

  int getIntArgLessOrEqualThan({required String name, required RawCommand from, required int max}) {
    int value = getArg(name: name, from: from);
    if (value > max) throw Exception("'$name' must be less than or equal to '$max'");

    return value;
  }
}



extension CommandDefinitionStringExtensions on CommandDefinition {
  Alignment getAlignmentArg({required String name, required RawCommand from}) {
    String alignmentAsString = getArg(name: name, from: from).toString();

    try {
      return _parseAlignment(alignmentAsString);
    } catch (e) {
      throw Exception("'$name' has an invalid alignment value: '$alignmentAsString'");
    }
  }


    static final _customAlignmentRegExp = RegExp(r'^-?(1(\.0)?|0(\.[0-9]+)?)/-?(1(\.0)?|0(\.[0-9]+)?)$');

    Alignment _parseAlignment(String alignment) {
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
        default: throw Exception("Unknown alignment value");
    }
  }
}