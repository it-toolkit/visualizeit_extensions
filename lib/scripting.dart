library visualizeit_extensions;

import 'dart:core';

import 'common.dart';
import 'extension.dart';


typedef _Int = int;
typedef _Double = double;

class ArgType<Type> {
  static ArgType string = ArgType<String>("string", (value) => value is String ? value : (value?.toString())
      .throwIfNull(Exception("Cannot convert '$value' to string")));
  static ArgType optionalString = ArgType<String?>("optionalString", string._convert);
  static ArgType stringArray = ArgType<String>("stringArray", string._convert, array: true);

  static ArgType int = ArgType<_Int>("int", (value) => value is num ? value.toInt() : _Int.tryParse(value.toString())
      .throwIfNull(Exception("Cannot convert '$value' to int")));
  static ArgType intArray = ArgType<_Int>("intArray", int._convert, array: true);

  static ArgType double = ArgType<_Double>("double", (value) => value is num ? value.toDouble() : _Double.tryParse(value.toString())
      .throwIfNull(Exception("Cannot convert '$value' to double")));
  static ArgType doubleArray = ArgType<_Double>("doubleArray", double._convert, array: true);

  static ArgType boolean = ArgType<bool>("boolean", (value) => value is bool ? value : bool.tryParse(value.toString(), caseSensitive: false)
      .throwIfNull(Exception("Cannot convert '$value' to boolean")));

  final String typeName;
  final bool optional;
  final bool array;
  final dynamic Function(dynamic) _convert;
  
  ArgType(this.typeName, this._convert, {this.array = false}): optional = _isNullable<Type>();

  static bool _isNullable<T>() => null is T;

  dynamic convert(dynamic value){
    if ((optional) && value == null) return null;

    if (value is Type || (array && value is List<Type>)) return value;

    try {
      if (array) return (value as Iterable).map((e) => _convert(e) as Type).toList() ;

      return _convert(value);
    } catch (e) {
      throw Exception("Cannot convert '$value' to $typeName");
    }
  }
  
  @override
  String toString() => typeName;
}

class CommandArgDef<Type> {
  String name;
  ArgType<Type> type;
  bool required;
  dynamic defaultValue;

  CommandArgDef(this.name, this.type, {this.required = true, this.defaultValue});

  dynamic convert(dynamic value) {
    return type.convert(value);
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

    if (from is RawCommandWithPositionalArgs && argPosition < from.args.length) {
      return argDef.convert(from.getArg(argPosition));
    } else if (from is RawCommandWithPositionalArgs && !argDef.required) {
      return argDef.convert(argDef.defaultValue);
    } else if (from is RawCommandWithNameArgs && from.containsArg(argDef.name)) {
      return argDef.convert(from.getArg(name));
    } else if (from is RawCommandWithNameArgs && !argDef.required) {
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

abstract interface class Scripting {
  List<CommandDefinition> getAllCommandDefinitions();

  ///Returns a valid command if a compatible [CommandDefinition] is found or null otherwise
  Command? buildCommand(RawCommand rawCommand);
}

class CommandMetadata {
  final int scriptLineIndex;

  CommandMetadata(this.scriptLineIndex);

  @override
  String toString() {
    return 'CommandMetadata{scriptLineIndex: $scriptLineIndex}';
  }
}

abstract class RawCommand {
  final String name;
  final CommandMetadata? metadata;

  int argsLength();

  bool isCompliantWith(CommandDefinition commandDefinition) {
    var namespace = "${commandDefinition.extensionId}.";

    bool isFullyQualifiedName = name.startsWith(namespace);
    if (isFullyQualifiedName) {
      return commandDefinition.name == name.replaceFirst(namespace, "");
    }

    return commandDefinition.name == name;
  }

  const RawCommand._(this.name, { this.metadata }); // Private constructor

  factory RawCommand.literal(String name, {CommandMetadata? metadata}) = RawLiteralCommand;
  factory RawCommand.withPositionalArgs(String name, List<dynamic> args, {CommandMetadata? metadata}) = RawCommandWithPositionalArgs;
  factory RawCommand.withNamedArgs(String name, Map<String, dynamic> namedArgs, {CommandMetadata? metadata}) = RawCommandWithNameArgs;
}

class RawLiteralCommand extends RawCommand {
  RawLiteralCommand(super.name, {super.metadata}) : super._(); // Private constructor

  @override
  int argsLength() => 0;

  @override
  bool isCompliantWith(CommandDefinition commandDefinition) {
    return super.isCompliantWith(commandDefinition) && commandDefinition.args.isEmpty;
  }

  @override
  String toString() => 'RawLiteralCommand {name=$name}';
}

class RawCommandWithPositionalArgs extends RawCommand {
  final List<dynamic> args;

  RawCommandWithPositionalArgs(super.name, this.args, {super.metadata})
      : super._(); // Private constructor

  @override
  int argsLength() => args.length;

  @override
  bool isCompliantWith(CommandDefinition commandDefinition) {
    return super.isCompliantWith(commandDefinition) &&
        // (commandDefinition.args.length >= args.length) &&
        (commandDefinition.args.length == args.length || _missingArgsAreNotRequired(commandDefinition));
  }

  bool _missingArgsAreNotRequired(CommandDefinition commandDefinition) {
    for(int i = args.length; i < commandDefinition.args.length; i++){
      if (commandDefinition.args[i].required) return false;
    }

    return true;
  }

  dynamic getArg(int index) => index < args.length ? args[index] : null;

  @override
  String toString() => 'RawLiteralCommand {name=$name, args=$args}';
}

class RawCommandWithNameArgs extends RawCommand {
  final Map<String, dynamic> namedArgs;

  RawCommandWithNameArgs(super.name, this.namedArgs, {super.metadata})
      : super._(); // Private constructor

  @override
  int argsLength() => namedArgs.length;

  @override
  bool isCompliantWith(CommandDefinition commandDefinition) {
    return super.isCompliantWith(commandDefinition) &&
        // (commandDefinition.args.length >= namedArgs.keys.length) &&
        (commandDefinition.args.every((arg) => namedArgs.containsKey(arg.name) || !arg.required));
  }

  bool containsArg(String name) => namedArgs.containsKey(name);

  dynamic getArg(String name) => namedArgs[name];

  @override
  String toString() => 'RawLiteralCommand {name=$name, args=$namedArgs}';
}
