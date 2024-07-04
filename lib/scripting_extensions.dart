

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
      throw Exception("'$name' has an invalid alignment value: '$alignmentAsString'\nSupported values ${_AlignmentValues.values.map((e) => e.name)}");
    }
  }

  BoxFit getBoxFitArg({required String name, required RawCommand from}) {
    String boxFitAsString = getArg(name: name, from: from).toString();

    try {
      return BoxFit.values.byName(boxFitAsString);
    } catch (e) {
      throw Exception("'$name' has an invalid box fit value: '$boxFitAsString'\nSupported values ${BoxFit.values.map((e) => e.name)}");
    }
  }


  static final _customAlignmentRegExp = RegExp(r'^-?(1(\.0)?|0(\.[0-9]+)?)/-?(1(\.0)?|0(\.[0-9]+)?)$');

  Alignment _parseAlignment(String alignment) {
    if(_customAlignmentRegExp.hasMatch(alignment)) {
      final alignmentParts = alignment.split("/");
      return Alignment(double.parse(alignmentParts[0]), double.parse(alignmentParts[1]));
    }

    final alignmentEnumValue = _AlignmentValues.values.byName(alignment);

    switch(alignmentEnumValue) {
      case _AlignmentValues.topLeft: return Alignment.topLeft;
      case _AlignmentValues.topCenter: return Alignment.topCenter;
      case _AlignmentValues.topRight: return Alignment.topRight;
      case _AlignmentValues.centerLeft: return Alignment.centerLeft;
      case _AlignmentValues.center: return Alignment.center;
      case _AlignmentValues.centerRight: return Alignment.centerRight;
      case _AlignmentValues.bottomLeft: return Alignment.bottomLeft;
      case _AlignmentValues.bottomCenter: return Alignment.bottomCenter;
      case _AlignmentValues.bottomRight: return Alignment.bottomRight;
      default: throw Exception("Unknown alignment value");
    }
  }
}

enum _AlignmentValues {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}