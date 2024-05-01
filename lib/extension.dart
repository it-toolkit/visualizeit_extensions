
import 'package:visualizeit_extensions/scripting.dart';
import 'package:visualizeit_extensions/visualizer.dart';

typedef ExtensionId = String;

class Extension {
  ExtensionId extensionId;
  ScriptingExtension scripting;
  VisualizerExtension visualizer;

  Extension(this.extensionId, this.scripting, this.visualizer);
}

abstract class ExtensionBuilder {
  Extension build();
}