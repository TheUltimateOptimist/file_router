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
}
