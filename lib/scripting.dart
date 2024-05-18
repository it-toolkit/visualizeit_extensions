library visualizeit_extensions;

import 'common.dart';
import 'extension.dart';

enum ArgType { string, int, double, boolean, stringArray, optionalString }

class CommandArgDef {
  String name;
  ArgType type;
  bool required;
  String? defaultValue;

  CommandArgDef(this.name, this.type, {this.required = true, this.defaultValue});

  dynamic convert(dynamic value) {
    return switch (type) {
      ArgType.string => value is String ? value : value.toString(),
      ArgType.optionalString => value is String? ? value : value?.toString(),
      ArgType.int => value is num
          ? value.toInt()
          : int.tryParse(value.toString())
              .throwIfNull(Exception("Cannot convert '$value' to $type")),
      ArgType.double => value is num
          ? value.toDouble()
          : double.tryParse(value.toString())
              .throwIfNull(Exception("Cannot convert '$value' to $type")),
      ArgType.boolean => value is bool
          ? value
          : bool.tryParse(value.toString(), caseSensitive: false)
              .throwIfNull(Exception("Cannot convert '$value' to $type")),
      ArgType.stringArray => value is List<String>
          ? value
          : (value is List ? value.map((e) => e.toString()).toList() : null)
              .throwIfNull(Exception("Cannot convert '$value' to $type"))
    };
  }
}

extension _DynamicExtension on dynamic {
  dynamic throwIfNull(Exception exception) {
    if (this == null) throw exception;

    return this;
  }
}

class CommandDefinition {
  ExtensionId extensionId;
  String name;
  List<CommandArgDef> args;

  CommandDefinition(this.extensionId, this.name, this.args);

  dynamic getArg({required String name, required RawCommand from}) {
    final argPosition = _getArgPositionByName(name);
    final argDef = args[argPosition];

    if (from is RawCommandWithPositionalArgs) {
      return argDef.convert(from.getArg(argPosition));
    } else if (from is RawCommandWithNameArgs && from.containsArg(argDef.name)) {
      return argDef.convert(from.getArg(name));
    } else if (from is RawCommandWithNameArgs && !from.containsArg(argDef.name) && !argDef.required) {
      return argDef.convert(argDef.defaultValue);
    }

    throw Exception("Unexpected raw command type: $from");
  }

  int _getArgPositionByName(String name) {
    var index = args.indexWhere((arg) => arg.name == name);
    if (index < 0) throw Exception("Unknown argument name: $name");
    return index;
  }
}

abstract interface class ScriptingExtension {
  List<CommandDefinition> getAllCommandDefinitions();

  ///Returns a valid command if a compatible [CommandDefinition] is found or null otherwise
  Command? buildCommand(RawCommand rawCommand);
}

class DefaultScriptingExtension implements ScriptingExtension {
  final Map<CommandDefinition, Command Function(RawCommand)> _config;
  List<CommandDefinition>? _allCommandDefinitions;

  DefaultScriptingExtension(
      Map<CommandDefinition, Command Function(RawCommand)> supportedCommands)
      : _config = Map.from(supportedCommands);

  @override
  Command? buildCommand(RawCommand rawCommand) {
    final def = getMatchingCommandDefinition(rawCommand);
    if (def == null) return null;

    return _config[def]?.call(rawCommand);
  }

  @override
  List<CommandDefinition> getAllCommandDefinitions() {
    return _allCommandDefinitions ??= _config.keys.toList();
  }

  CommandDefinition? getMatchingCommandDefinition(RawCommand rawCommand) {
    return getAllCommandDefinitions()
        .where((commandDefinition) => rawCommand.isCompliantWith(commandDefinition))
        .singleOrNull;
  }
}

abstract class RawCommand {
  final String name;

  int argsLength();

  bool isCompliantWith(CommandDefinition commandDefinition);

  const RawCommand._(this.name); // Private constructor

  factory RawCommand.literal(String name) = RawLiteralCommand;
  factory RawCommand.withPositionalArgs(String name, List<dynamic> args) =
      RawCommandWithPositionalArgs;
  factory RawCommand.withNamedArgs(
      String name, Map<String, dynamic> namedArgs) = RawCommandWithNameArgs;
}

class RawLiteralCommand extends RawCommand {
  RawLiteralCommand(super.name) : super._(); // Private constructor

  @override
  int argsLength() => 0;

  @override
  bool isCompliantWith(CommandDefinition commandDefinition) {
    return commandDefinition.name == name && commandDefinition.args.isEmpty;
  }

  @override
  String toString() => 'RawLiteralCommand {name=$name}';
}

class RawCommandWithPositionalArgs extends RawCommand {
  final List<dynamic> args;

  RawCommandWithPositionalArgs(super.name, this.args)
      : super._(); // Private constructor

  @override
  int argsLength() => args.length;

  @override
  bool isCompliantWith(CommandDefinition commandDefinition) {
    return commandDefinition.name == name && commandDefinition.args.length == args.length;
  }

  dynamic getArg(int index) => args[index];

  @override
  String toString() => 'RawLiteralCommand {name=$name, args=$args}';
}

class RawCommandWithNameArgs extends RawCommand {
  final Map<String, dynamic> namedArgs;

  RawCommandWithNameArgs(super.name, this.namedArgs)
      : super._(); // Private constructor

  @override
  int argsLength() => namedArgs.length;

  @override
  bool isCompliantWith(CommandDefinition commandDefinition) {
    return commandDefinition.name == name
        && commandDefinition.args.every((arg) => namedArgs.containsKey(arg.name) || !arg.required);
  }

  bool containsArg(String name) => namedArgs.containsKey(name);

  dynamic getArg(String name) => namedArgs[name];

  @override
  String toString() => 'RawLiteralCommand {name=$name, args=$namedArgs}';
}
