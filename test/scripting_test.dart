import 'package:flutter_test/flutter_test.dart';
import 'package:visualizeit_extensions/scripting.dart';

void main() {
  final commandDefinition = CommandDefinition(
      "an-extension-id",
      "a-command-name", [
        CommandArgDef("param1", ArgType.string),
        CommandArgDef("param2", ArgType.int),
        CommandArgDef("param3", ArgType.double),
        CommandArgDef("param4", ArgType.boolean),
        CommandArgDef("param5", ArgType.stringArray),
        CommandArgDef("optionalParam1", ArgType.double, required: false, defaultValue: "1.0"),
      ],
  );

  final rawLiteralCommand = RawCommand.literal("a-command-name");

  final rawCommandWithPositionalArgs = RawCommand.withPositionalArgs("a-command-name", ["text", 1, 2.3, true, ["a", "2"], 1.0]);
  final rawCommandWithPositionalArgsAndMissingOptionalParam = RawCommand.withPositionalArgs("a-command-name", ["text", 1, 2.3, true, ["a", "2"]]);
  final rawCommandWithPositionalCastableArgs = RawCommand.withPositionalArgs("a-command-name", ["text", "1", "2.3", "true", ["a", 2], "1.0"]);
  final rawCommandWithNamedArgs = RawCommand.withNamedArgs("a-command-name", {"param1": "text", "param2": 1, "param3": 2.3, "param4": true, "param5": ["a", "2"], "optionalParam1" : 1.0});
  final rawCommandWithNamedCastableArgs = RawCommand.withNamedArgs("a-command-name", {"param1": "text", "param2": "1", "param3": "2.3", "param4": "true", "param5": ["a", 2], "optionalParam1" : "1.0"});
  final rawCommandWithNamedArgsAndMissingOptionalParam = RawCommand.withNamedArgs("a-command-name", {"param1": "text", "param2": 1, "param3": 2.3, "param4": true, "param5": ["a", "2"]});

  final rawCommandWithArgs = [rawCommandWithPositionalArgs, rawCommandWithPositionalArgsAndMissingOptionalParam, rawCommandWithPositionalCastableArgs, rawCommandWithNamedArgs, rawCommandWithNamedCastableArgs, rawCommandWithNamedArgsAndMissingOptionalParam];

  final rawCommandWithInvalidPositionalArgs = RawCommand.withPositionalArgs("a-command-name", [null, "a", "b", "c", {"a": "2"}, "a"]);

  test('throw error when try to get an arg for a command without args', () {
    expect(() => commandDefinition.getArg(name: "param1", from: rawLiteralCommand), throwsA(isA<Exception>()));
  });

  test('throw error when try to get an unknown arg for a command', () {
    for (var rawCommand in rawCommandWithArgs) {
      expect(() => commandDefinition.getArg(name: "unknownParam", from: rawCommand), throwsA(isA<Exception>()));
    }
  });

  test('throw error when try to get an arg with invalid type', () {
    expect(commandDefinition.getArg(name: "param1", from: rawCommandWithInvalidPositionalArgs), equals("null"));

    expect(() => commandDefinition.getArg(name: "param2", from: rawCommandWithInvalidPositionalArgs), throwsA(isA<Exception>()));
    expect(() => commandDefinition.getArg(name: "param3", from: rawCommandWithInvalidPositionalArgs), throwsA(isA<Exception>()));
    expect(() => commandDefinition.getArg(name: "param4", from: rawCommandWithInvalidPositionalArgs), throwsA(isA<Exception>()));
    expect(() => commandDefinition.getArg(name: "param5", from: rawCommandWithInvalidPositionalArgs), throwsA(isA<Exception>()));
    expect(() => commandDefinition.getArg(name: "optionalParam1", from: rawCommandWithInvalidPositionalArgs), throwsA(isA<Exception>()));
  });

  test('get proper casted arg values from raw commands', () {
    for (var rawCommand in rawCommandWithArgs) {
      expect(commandDefinition.getArg(name: "param1", from: rawCommand), equals("text"));
      expect(commandDefinition.getArg(name: "param2", from: rawCommand), equals(1));
      expect(commandDefinition.getArg(name: "param3", from: rawCommand), equals(2.3));
      expect(commandDefinition.getArg(name: "param4", from: rawCommand), equals(true));
      expect(commandDefinition.getArg(name: "param5", from: rawCommand), equals(["a", "2"]));
      expect(commandDefinition.getArg(name: "optionalParam1", from: rawCommand), equals(1.0));
    }
  });
}