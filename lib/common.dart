
abstract class Command {

}

abstract class ModelCommand implements Command {
  String modelName;

  ModelCommand(this.modelName);

  void call(Model model);
}

abstract class ModelBuilderCommand implements Command {
   Model call();
}

abstract class Model {
  String name;

  Model(this.name);

  void apply(Command command);
}