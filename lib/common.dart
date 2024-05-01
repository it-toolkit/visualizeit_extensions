
import 'extension.dart';

abstract class Command {}

abstract class ModelCommand implements Command {
  String modelName;

  ModelCommand(this.modelName);

  Result call(Model model);
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
   Model call();
}

abstract class Model {
  ExtensionId extensionId;
  String name;

  Model(this.extensionId, this.name);

  Model clone();
}