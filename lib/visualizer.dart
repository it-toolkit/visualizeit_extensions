library visualizeit_extensions;

import 'package:flutter/cupertino.dart';

import 'common.dart';



abstract class VisualizerExtension {
  Widget? render(Model model, BuildContext context);
}