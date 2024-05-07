
import 'extension.dart';

abstract class Command {}

class CommandContext {
  Duration timeFrame;

  CommandContext({this.timeFrame = Duration.zero});

  @override
  String toString() => 'CommandContext{timeFrame: $timeFrame}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CommandContext && runtimeType == other.runtimeType && timeFrame == other.timeFrame;

  @override
  int get hashCode => timeFrame.hashCode;
}

mixin CommandExecutionAware {
  Duration timeFrame = Duration.zero;
}

abstract class ModelCommand implements Command {
  String modelName;

  ModelCommand(this.modelName);

  Result call(Model model, CommandContext context);
}

class Result {
  bool finished;
  Model? model;

  Result({this.finished = true, this.model});

  @override
  String toString() {
    return 'Result{finished: $finished, model: $model}';
  }
}

abstract class ModelBuilderCommand implements Command {
   Model call(CommandContext context);
}

abstract class Model {
  ExtensionId extensionId;
  String name;

  Model(this.extensionId, this.name);

  Model clone();
}