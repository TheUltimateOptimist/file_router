import 'dart:io';
import 'package:path/path.dart';

extension DirExtension on Directory {
  String get name => basename(path);
}

extension FileExtension on File {
  ///checks wheter the file contains a class declaration for the given className
  bool containsClass(String className) =>
      RegExp(r"class\s+\" + className).hasMatch(readAsStringSync());

  String get name => basename(path);

  void insertAfterImports(String source, {int topLineSpacing = 0, int bottomLineSpacing = 0}) {
    final lines = readAsLinesSync();
    int insertAt = 0;
    while (insertAt < lines.length &&
        (lines[insertAt].trim().startsWith("import") ||
            lines[insertAt].startsWith("//") ||
            lines[insertAt].trim().isEmpty)) {
      insertAt++;
    }
    final top = "\n" * topLineSpacing;
    final bottom = "\n" * bottomLineSpacing;
    lines.insert(insertAt, "$top$source$bottom");
    writeAsStringSync(lines.join("\n"));
  }

  void addImport(String path, {String? as}) {
    if (!readAsStringSync().contains(path)) {
      insertAfterImports("import '$path'${as != null ? ' as $as' : ''};");
    }
  }
}
