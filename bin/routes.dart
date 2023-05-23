import 'extensions/string.dart';
import 'params.dart';

abstract class Route {
  Route(this.folderPath, this.fileName, this.previous);

  final String folderPath;
  final String fileName;
  final Route? previous;
  List<Route> children = List.empty(growable: true);

  String get filePath => "$folderPath/$fileName";

  String get name;

  String toCustomString(String leftSpace);
}

class ShellRoute extends Route {
  ShellRoute(super.folderPath, super.fileName, super.previous);

  @override
  String get name {
    //example: "{root_shell}.dart" -> "RootShell"
    return fileName.replaceAll("}", "{").split("{")[1].snakeToPascalCase();
  }

  @override
  String toCustomString(String leftSpace) {
    String result = "ShellRoute($folderPath, $fileName)";
    for (final child in children) {
      result += "\n$leftSpace|-->${child.toCustomString('$leftSpace    ')}";
    }
    return result;
  }
}

class RegularRoute extends Route {
  RegularRoute(
    super.folderPath,
    super.fileName,
    super.previous,
    this.relativeUrl,
    this.params,
  );

  final String relativeUrl;
  final List<Param> params;

  @override
  String get name {
    //example: "+home_page.dart" -> "HomePage"
    return fileName.replaceAll("+", "").split(".dart")[0].snakeToPascalCase();
  }

  @override
  String toCustomString(String leftSpace) {
    String result = "RegularRoute($folderPath, $fileName, $relativeUrl)";
    for (final param in params) {
      result += "\n$leftSpace${param.toString()}";
    }
    for (final child in children) {
      result += "\n$leftSpace|-->${child.toCustomString("$leftSpace    ")}";
    }
    return result;
  }
}
