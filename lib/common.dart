
import 'package:visualizeit_extensions/scripting.dart';

import 'extension.dart';

abstract class Command {
  CommandMetadata? metadata;
}

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

mixin CommandExecutionAware on Model {
  Duration _timeFrame = Duration.zero;
  int _framesDuration = 1;
  int _pendingFrames = 1;

  get pendingFrames => _pendingFrames;
  get timeFrame => _timeFrame;
  get isLastFrame => _pendingFrames == 1;
  get isFinished => _pendingFrames <= 0;

  ///Setups the current command expected duration in frames amount
  ///
  ///Returns the current model for method chaining
  Model withFramesDuration(int framesDuration) {
    _pendingFrames = framesDuration;
    return this;
  }

  ///Updates the command execution state using [CommandContext] data (like current command time frame)
  ///
  ///Returns the current model for method chaining
  Model updateCommandExecutionState(CommandContext context) {
    _timeFrame = context.timeFrame;
    return this;
  }

  ///Decrements the pending frames count and updates the command execution state using [CommandContext] data (like current command time frame).
  ///
  ///Returns the current model for method chaining
  Model consumePendingFrame(CommandContext context){
    _timeFrame = context.timeFrame;
    _pendingFrames--;
    return this;
  }

  ///Copies the state of the provided [source] into the caller [CommandExecutionAware] instance
  void withCommandExecutionStateFrom(CommandExecutionAware source){
    _timeFrame = source._timeFrame;
    _framesDuration = source._framesDuration;
    _pendingFrames = source._pendingFrames;
  }
}

abstract class ModelCommand extends Command {
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

abstract class ModelBuilderCommand extends Command {
   Model call(CommandContext context);
}

abstract class Model {
  ExtensionId extensionId;
  String name;

  Model(this.extensionId, this.name);

  Model clone();
}