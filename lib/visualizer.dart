library visualizeit_extensions;

import 'package:flutter/widgets.dart';
import 'package:visualizeit_extensions/logging.dart';

import 'common.dart';

final _logger = Logger("extension.visualizer");

///Used to bind the extension with VisualizeIT visualizer module
abstract class Renderer {
  ///Returns an iterable list of widgets representing the provided [model] state
  Iterable<Widget> renderAll(Model model, BuildContext context);
}

///Rendering priority mixin can be used to set up a priority used to order
///the z-index of the widgets rendered in VisualizeIt canvas.
///
///Widgets with higher rendering priority will be rendered in top of lower priority widget
mixin RenderingPriority on Widget {
  static const minPriority = -1000;
  static const maxPriority = 1000;
  static const defaultPriority = 0;

  late final int _priority;

  ///Rendering priority value
  int get priority => _priority;

  ///Setups the rendering priority
  ///
  /// The value must be >= [minPriority] (-1000) and <= [maxPriority] (1000)
  void initPriority(int priority) {
    if (priority < minPriority || priority > maxPriority) {
      _logger.warn(() => "Priority not update to $priority due out of range [$minPriority, $maxPriority]");
    } else {
      _priority = priority;
    }
  }
}