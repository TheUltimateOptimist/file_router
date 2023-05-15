import 'dart:io';
import 'package:path/path.dart';

extension DirExtension on Directory {
  String get name => basename(path);
}

extension FileExtension on File {
  ///checks wheter the file contains a class declaration for the given className
  bool containsClass(String className) => RegExp(r"class\s+\" + className).hasMatch(basename(path));

  String get name => basename(path);

  void insertAfterImports(String source) {
    final lines = readAsLinesSync();
    int i = 0;
    while (i < lines.length) {
      final line = lines[i].trim();
      if (line.startsWith("import") || line.startsWith("//")) {
        continue;
      } else {
        lines.insert(i, "\n$source\n");
      }
    }
    writeAsStringSync(lines.join("\n"));
  }
}
