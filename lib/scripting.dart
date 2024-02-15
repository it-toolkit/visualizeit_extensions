library visualizeit_extensions;

import 'common.dart';

enum ArgType {
  string,
  int,
  double,
  boolean
}

class CommandArgDef {
  String name;
  ArgType type;

  CommandArgDef(this.name, this.type);
}

class CommandDefinition {
  String extensionId;
  String name;
  List<CommandArgDef> args;

  CommandDefinition(this.extensionId, this.name, this.args);
}

abstract class ScriptingExtension {
  List<CommandDefinition> getAllCommandDefinitions();

  ///Returns a valid command if a compatible [CommandDefinition] is found or null otherwise
  Command? buildCommand(String name, List<String> args);
}