extension StringExtensions on String {
  String transformFirst(String Function(String first) transformer) {
    if (isEmpty) {
      return this;
    }
    return transformer(this[0]) + substring(1);
  }

  String capitalize() => transformFirst((first) => first.toUpperCase());

  String uncapitalize() => transformFirst((first) => first.toLowerCase());

  String snakeToPascalCase() => split("_").map((word) => word.capitalize()).join("");

  String snakeToCamelCase() => snakeToPascalCase().uncapitalize();

  String withoutSurroundingChars() => substring(1, length - 1);

  String surroundWith(String left, {String? right, bool ifEmpty = true}) {
    right ??= left;
    if (isEmpty && !ifEmpty) {
      return "";
    }
    return "$left$this$right";
  }
}
