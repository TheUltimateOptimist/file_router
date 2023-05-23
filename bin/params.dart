class Param {
  const Param(this.fullName, this.name, this.type);

  final String fullName;
  final String name;
  final String type;

  bool get typeBuiltIn {
    const types = ["int", "int?", "String", "String?", "bool", "bool?", "double", "double?"];
    return types.contains(type);
  }
}

class Optional extends Param {
  const Optional(
    super.fullName,
    super.name,
    super.type, {
    this.defaultValue,
    this.importDefault = false,
  });

  final String? defaultValue;
  final bool importDefault;

  bool get isRequired => defaultValue == null && !importDefault && !type.endsWith("?");
}

class UrlParam extends Param {
  const UrlParam(super.fullName, super.name, super.type);

  @override
  String toString() => "UrlParam($fullName, $name, $type)";
}

class QueryParam extends Optional {
  const QueryParam(
    super.fullName,
    super.name,
    super.type, {
    super.defaultValue,
    super.importDefault = false,
  });

  @override
  String toString() => "QueryParam($fullName, $name, $type, $defaultValue, $importDefault)";
}

class ExtraParam extends Optional {
  const ExtraParam(
    super.fullName,
    super.name,
    super.type, {
    super.defaultValue,
    super.importDefault = false,
  });

  @override
  String toString() => "ExtraParam($fullName, $name, $type, $defaultValue, $importDefault)";
}
