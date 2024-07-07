

import 'package:flutter/widgets.dart';
import 'package:visualizeit_extensions/scripting.dart';

extension CommandDefinitionIntExtensions on CommandDefinition {

  ///Returns an integer value validating if it is in range[[min] , [max]], for the provided argument name
  ///
  ///It throws an exception if:
  ///* There no argument definition related to the provided name
  ///* The value cannot be converted to the argument related type.
  ///* The integer value is not in range [[min] , [max]]
  int getIntArgInRange({required String name, required RawCommand from, required int min, required int max}) {
    int value = getArg(name: name, from: from);
    if (value < min || value > max) throw Exception("'$name' must be in range [ $min , $max ]");

    return value;
  }

  ///Returns an integer value validating if it is greater than or equals to [min], for the provided argument name
  ///
  ///It throws an exception if:
  ///* There no argument definition related to the provided name
  ///* The value cannot be converted to the argument related type.
  ///* The integer value is less than [min]
  int getIntArgGreaterOrEqualThan({required String name, required RawCommand from, required int min}) {
    int value = getArg(name: name, from: from);
    if (value < min) throw Exception("'$name' must be greater than or equal to '$min'");

    return value;
  }

  ///Returns an integer value validating if it is less than or equals to [max], for the provided argument name
  ///
  ///It throws an exception if:
  ///* There no argument definition related to the provided name
  ///* The value cannot be converted to the argument related type.
  ///* The integer value is greater than [max]
  int getIntArgLessOrEqualThan({required String name, required RawCommand from, required int max}) {
    int value = getArg(name: name, from: from);
    if (value > max) throw Exception("'$name' must be less than or equal to '$max'");

    return value;
  }
}



extension CommandDefinitionStringExtensions on CommandDefinition {

  ///Returns an [Alignment] value for the provided argument name
  ///
  ///It throws an exception if:
  ///* There no argument definition related to the provided name
  ///* The value is not an string that can be parsed as a valid [Alignment]
  ///
  /// Supported alignment values:
  ///* topLeft
  ///* topCenter
  ///* topRight
  ///* centerLeft
  ///* center
  ///* centerRight
  ///* bottomLeft
  ///* bottomCenter
  ///* bottomRight
  Alignment getAlignmentArg({required String name, required RawCommand from}) {
    String alignmentAsString = getArg(name: name, from: from).toString();

    try {
      return _parseAlignment(alignmentAsString);
    } catch (e) {
      throw Exception("'$name' has an invalid alignment value: '$alignmentAsString'\nSupported values ${_AlignmentValues.values.map((e) => e.name)}");
    }
  }

  ///Returns a [BoxFit] value for the provided argument name
  ///
  ///It throws an exception if:
  ///* There no argument definition related to the provided name
  ///* The value is not an string that can be parsed as a valid [BoxFit]
  ///
  /// Supported box fit values:
  ///* fill
  ///* contain
  ///* cover
  ///* fitWidth
  ///* fitHeight
  ///* none
  ///* scaleDown
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