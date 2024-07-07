library visualizeit_extensions;

import 'dart:core';

import 'common.dart';
import 'extension.dart';


typedef _Int = int;
typedef _Double = double;

class ArgType<Type> {
  ///Non null string
  static ArgType string = ArgType<String>("string", (value) => value is String ? value : (value?.toString())
      .throwIfNull(Exception("Cannot convert '$value' to string")));

  ///Optional string (can be null)
  static ArgType optionalString = ArgType<String?>("optionalString", string._convert);

  ///Array of non null string
  static ArgType stringArray = ArgType<String>("stringArray", string._convert, array: true);

  ///Non null integer
  ///
  ///Double values will be converted to integer
  static ArgType int = ArgType<_Int>("int", (value) => value is num ? value.toInt() : _Int.tryParse(value.toString())
      .throwIfNull(Exception("Cannot convert '$value' to int")));

  ///Array of non null integers
  static ArgType intArray = ArgType<_Int>("intArray", int._convert, array: true);

  ///Non null double
  static ArgType double = ArgType<_Double>("double", (value) => value is num ? value.toDouble() : _Double.tryParse(value.toString())
      .throwIfNull(Exception("Cannot convert '$value' to double")));
  ///Array of non null integers
  static ArgType doubleArray = ArgType<_Double>("doubleArray", double._convert, array: true);

  ///Non null boolean
  ///
  ///* 'true' and 'TRUE' will be considered as 'true'
  ///* 'false' and 'FALSE' will be considered as 'false'
  ///* Other values are invalid
  static ArgType boolean = ArgType<bool>("boolean", (value) => value is bool ? value : bool.tryParse(value.toString(), caseSensitive: false)
      .throwIfNull(Exception("Cannot convert '$value' to boolean")));

  final String typeName;
  final bool optional;
  final bool array;
  final dynamic Function(dynamic) _convert;
  
  ArgType(this.typeName, this._convert, {this.array = false}): optional = _isNullable<Type>();

  static bool _isNullable<T>() => null is T;

  ///Returns the value converted to the current type if allowed or throws an exception if that is not possible.
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
  ///Argument name as it must be written in scripts when using map notation
  String name;
  ///Argument type
  ArgType<Type> type;
  ///Marks an argument as required or optional (is false)
  ///
  /// When a required argument is not provided the parser will throw an exception
  bool required;
  ///Default value for optional (non [required]) argument
  ///
  ///The provided value must compatible with the argument [type]
  dynamic defaultValue;

  CommandArgDef(this.name, this.type, {this.required = true, this.defaultValue});

  dynamic convert(dynamic value) {
    return type.convert(value);
  }
}

class CommandDefinition {
  ///Id of the extension that this command definition is related to.
  ExtensionId extensionId;
  ///Command name as it must be written in scripts
  String name;
  ///List of supported command arguments
  List<CommandArgDef> args;

  CommandDefinition(this.extensionId, this.name, this.args);

  ///Returns the value of the argument by name
  ///
  ///It throws an exception if there no argument definition related to the provided name or if the value cannot be
  ///converted to the argument related type.
  dynamic getArg({required String name, required RawCommand from}) {
    final argPosition = _getArgPositionByName(name);
    final argDef = args[argPosition];

    if (from is _RawCommandWithPositionalArgs && argPosition < from.args.length) {
      return argDef.convert(from.getArg(argPosition));
    } else if (from is _RawCommandWithPositionalArgs && !argDef.required) {
      return argDef.convert(argDef.defaultValue);
    } else if (from is _RawCommandWithNameArgs && from.containsArg(argDef.name)) {
      return argDef.convert(from.getArg(name));
    } else if (from is _RawCommandWithNameArgs && !argDef.required) {
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

///Used to bind the extension supported commands with VisualizeIT scripting module
abstract interface class Scripting {
  ///Return all available command definitions
  List<CommandDefinition> getAllCommandDefinitions();

  ///Returns a valid command if a compatible [CommandDefinition] is found or null otherwise
  Command? buildCommand(RawCommand rawCommand);
}

///Parsed command additional info
class CommandMetadata {
  ///Command starting line index in the related script yaml
  final int scriptLineIndex;

  CommandMetadata(this.scriptLineIndex);

  @override
  String toString() {
    return 'CommandMetadata{scriptLineIndex: $scriptLineIndex}';
  }
}

///Raw command data parsed from script
abstract class RawCommand {
  final String name;
  final CommandMetadata? metadata;

  int argsLength();

  ///Returns 'true' if the raw command data can be used to build a command with the provided [CommandDefinition]
  bool isCompliantWith(CommandDefinition commandDefinition) {
    var namespace = "${commandDefinition.extensionId}.";

    bool isFullyQualifiedName = name.startsWith(namespace);
    if (isFullyQualifiedName) {
      return commandDefinition.name == name.replaceFirst(namespace, "");
    }

    return commandDefinition.name == name;
  }

  const RawCommand._(this.name, { this.metadata }); // Private constructor

  factory RawCommand.literal(String name, {CommandMetadata? metadata}) = _RawLiteralCommand;
  factory RawCommand.withPositionalArgs(String name, List<dynamic> args, {CommandMetadata? metadata}) = _RawCommandWithPositionalArgs;
  factory RawCommand.withNamedArgs(String name, Map<String, dynamic> namedArgs, {CommandMetadata? metadata}) = _RawCommandWithNameArgs;
}

extension _DynamicExtension on dynamic {
  dynamic throwIfNull(Exception exception) {
    if (this == null) throw exception;

    return this;
  }
}

class _RawLiteralCommand extends RawCommand {
  _RawLiteralCommand(super.name, {super.metadata}) : super._(); // Private constructor

  @override
  int argsLength() => 0;

  @override
  bool isCompliantWith(CommandDefinition commandDefinition) {
    return super.isCompliantWith(commandDefinition) && commandDefinition.args.isEmpty;
  }

  @override
  String toString() => 'RawLiteralCommand {name=$name}';
}

class _RawCommandWithPositionalArgs extends RawCommand {
  final List<dynamic> args;

  _RawCommandWithPositionalArgs(super.name, this.args, {super.metadata})
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

class _RawCommandWithNameArgs extends RawCommand {
  final Map<String, dynamic> namedArgs;

  _RawCommandWithNameArgs(super.name, this.namedArgs, {super.metadata})
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
