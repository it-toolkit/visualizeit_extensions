
import 'package:visualizeit_extensions/scripting.dart';

import 'extension.dart';

///Base class for all extension commands
abstract class Command {
  CommandMetadata? metadata;
}

///Provides additional command execution context information
class CommandContext {
  ///Time frame assigned for command execution
  ///
  /// This is useful to control time based animations. Keep in mind that commands executed during
  /// script initialization (those included in initial-state section) will have a 'zero' [Duration]
  /// timeFrame
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

///Mixin that provides support to handle multi frame commands duration
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

///Abstraction required to be the base of commands that must be applied on models built
///by other commands in the script
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

///Abstraction required to be the base of commands that build
///models to be used by other commands in the script
abstract class ModelBuilderCommand extends Command {
   Model call(CommandContext context);
}

///Abstraction required to be the base of extension models
abstract class Model {
  ///Id of the related extension
  ExtensionId extensionId;
  ///Unique name of the model.
  ///
  ///This is used to index and keep track of the model state during script execution
  String name;

  Model(this.extensionId, this.name);

  ///Returns a copy of the model to avoid undesired modifications in current model state.
  ///Only if the model is _**fully immutable**_ it is safe to return the current instance, otherwise a _**deep copy**_
  ///of the model must me performed.
  ///
  ///This is used to provide a safe copy of the current model state to perform command actions.
  Model clone();
}