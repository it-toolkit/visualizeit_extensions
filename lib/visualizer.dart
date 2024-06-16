library visualizeit_extensions;

import 'package:flutter/widgets.dart';
import 'package:visualizeit_extensions/logging.dart';

import 'common.dart';

final _logger = Logger("extension.visualizer");

abstract class Renderer {
  Iterable<Widget> renderAll(Model model, BuildContext context);
}

mixin RenderingPriority on Widget {
  static const minPriority = -1000;
  static const maxPriority = 1000;
  static const defaultPriority = 0;

  late final int _priority;

  int get priority => _priority;

  void initPriority(int priority) {
    if (priority < minPriority || priority > maxPriority) {
      _logger.warn(() => "Priority not update to $priority due out of range [$minPriority, $maxPriority]");
    } else {
      _priority = priority;
    }
  }
}