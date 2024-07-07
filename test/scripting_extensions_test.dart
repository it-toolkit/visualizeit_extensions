import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:visualizeit_extensions/scripting_extensions.dart';

RawCommand _rawCommand(dynamic paramValue) => RawCommand.withPositionalArgs("cmd-1", [paramValue]);

void main() {

  group("Command definition integer extensions", () {
    final commandDefinition = CommandDefinition("eid", "cmd-1", [CommandArgDef("param1", ArgType.int)]);

    final rawCommand = RawCommand.withPositionalArgs("cmd-1", [5]);
    test('get proper casted and valid arg values from raw commands', () {
      expect(commandDefinition.getIntArgGreaterOrEqualThan(name: "param1", from: rawCommand, min: 0), equals(5));
      expect(commandDefinition.getIntArgGreaterOrEqualThan(name: "param1", from: rawCommand, min: 5), equals(5));

      expect(commandDefinition.getIntArgLessOrEqualThan(name: "param1", from: rawCommand, max: 5), equals(5));
      expect(commandDefinition.getIntArgLessOrEqualThan(name: "param1", from: rawCommand, max: 10), equals(5));

      expect(commandDefinition.getIntArgInRange(name: "param1", from: rawCommand, min: 0, max: 10), equals(5));
      expect(commandDefinition.getIntArgInRange(name: "param1", from: rawCommand, min: 5, max: 5), equals(5));
    });

    test('throw error when try to get an invalid arg', () {
      expect(() => commandDefinition.getIntArgGreaterOrEqualThan(name: "param1", from: rawCommand, min: 6), throwsA(isA<Exception>()));

      expect(() => commandDefinition.getIntArgLessOrEqualThan(name: "param1", from: rawCommand, max: 4), throwsA(isA<Exception>()));

      expect(() => commandDefinition.getIntArgInRange(name: "param1", from: rawCommand, min: 6, max: 10), throwsA(isA<Exception>()));
      expect(() => commandDefinition.getIntArgInRange(name: "param1", from: rawCommand, min: 1, max: 4), throwsA(isA<Exception>()));
    });
  });

  group("Command definition string extensions", () {
    final commandDefinition = CommandDefinition("eid", "cmd-1", [CommandArgDef("param1", ArgType.string)]);

    test('get proper casted and valid arg alignment value from raw commands', () {
      expect(commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("topLeft")), equals(Alignment.topLeft));
      expect(commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("topCenter")), equals(Alignment.topCenter));
      expect(commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("topRight")), equals(Alignment.topRight));
      expect(commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("centerLeft")), equals(Alignment.centerLeft));
      expect(commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("center")), equals(Alignment.center));
      expect(commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("centerRight")), equals(Alignment.centerRight));
      expect(commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("bottomLeft")), equals(Alignment.bottomLeft));
      expect(commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("bottomCenter")), equals(Alignment.bottomCenter));
      expect(commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("bottomRight")), equals(Alignment.bottomRight));
    });

    test('get proper casted and valid arg box fit value from raw commands', () {
      expect(commandDefinition.getBoxFitArg(name: "param1", from: _rawCommand("fill")), equals(BoxFit.fill));
      expect(commandDefinition.getBoxFitArg(name: "param1", from: _rawCommand("contain")), equals(BoxFit.contain));
      expect(commandDefinition.getBoxFitArg(name: "param1", from: _rawCommand("cover")), equals(BoxFit.cover));
      expect(commandDefinition.getBoxFitArg(name: "param1", from: _rawCommand("fitWidth")), equals(BoxFit.fitWidth));
      expect(commandDefinition.getBoxFitArg(name: "param1", from: _rawCommand("fitHeight")), equals(BoxFit.fitHeight));
      expect(commandDefinition.getBoxFitArg(name: "param1", from: _rawCommand("none")), equals(BoxFit.none));
      expect(commandDefinition.getBoxFitArg(name: "param1", from: _rawCommand("scaleDown")), equals(BoxFit.scaleDown));
    });

    test('throw error when try to get an invalid arg value', () {
      expect(() => commandDefinition.getAlignmentArg(name: "param1", from: _rawCommand("_invalid_")), throwsA(isA<Exception>()));

      expect(() => commandDefinition.getBoxFitArg(name: "param1", from: _rawCommand("_invalid_")), throwsA(isA<Exception>()));
    });
  });
}