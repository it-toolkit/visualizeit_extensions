
import 'package:flutter/widgets.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:visualizeit_extensions/visualizer.dart';

typedef ExtensionId = String;
typedef LanguageCode = String;

abstract class LanguageCodes {
  /// English language code
  static const en = "en";
  /// Spanish language code
  static const es = "es";
}

class Extension {
  ///Extension id to be used in scripts. The id can only contain letters, numbers and underscores.
  ExtensionId id;
  Scripting scripting;
  Renderer renderer;
  Map<LanguageCode, String> markdownDocs;

  Extension({required this.id, required this.scripting, required this.renderer, required this.markdownDocs}) {
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(id)) {
      throw Exception("Invalid extension id '$id', it must be compliant with regex r'^[a-zA-Z0-9_]\$'");
    }
  }

  Extension.create({required ExtensionId id, required Map<LanguageCode, String> markdownDocs, required ExtensionCore extensionCore})
    : this(id: id, scripting: extensionCore, renderer: extensionCore, markdownDocs: markdownDocs);
}

abstract class ExtensionBuilder {
  Future<Extension> build();
}

///Simplified Scripting and Renderer implementation based command definitions
///
///This abstraction is intended to be used when models have multi widget representations
///
///Only [Renderer.renderAll] method must be implemented
abstract class ExtensionCore implements Scripting, Renderer {
  final Map<CommandDefinition, Command Function(RawCommand)> _config;
  List<CommandDefinition>? _allCommandDefinitions;

  ExtensionCore(
      Map<CommandDefinition, Command Function(RawCommand)> supportedCommands)
      : _config = Map.from(supportedCommands);

  @override
  Command? buildCommand(RawCommand rawCommand) {
    final def = getMatchingCommandDefinition(rawCommand);
    if (def == null) return null;

    return _config[def]?.call(rawCommand)?..metadata = rawCommand.metadata;
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

///Simplified Scripting and Renderer implementation based on command definitions
///
///This abstraction is intended to be used when models have a single widget representations
///
///Only [SimpleExtensionCore.render] method must be implemented
abstract class SimpleExtensionCore extends ExtensionCore {
  SimpleExtensionCore(super.supportedCommands);

  @override
  Iterable<Widget> renderAll(Model model, BuildContext context) {
    final widget = render(model, context);
    return widget != null ? [widget] : [];
  }

  Widget? render(Model model, BuildContext context);
}