
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
  ExtensionId extensionId;
  ScriptingExtension scripting;
  VisualizerExtension visualizer;
  Map<LanguageCode, String> markdownDocs;

  Extension(this.extensionId, this.scripting, this.visualizer, this.markdownDocs);
}

abstract class ExtensionBuilder {
  Future<Extension> build();
}