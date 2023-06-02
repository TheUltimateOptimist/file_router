import 'extensions/string.dart';
import 'params.dart';

sealed class Route {
  Route(this.folderPath, this.fileName, this.previous, this.params);

  final String folderPath;
  final String fileName;
  final Route? previous;
  List<Route> children = List.empty(growable: true);
  final List<Param> params;

  String get filePath => "$folderPath/$fileName";

  String get pageName => getPageName(fileName);

  String get routeName => getRouteName(fileName);

  String toCustomString(String leftSpace);
}

class ShellRoute extends Route {
  ShellRoute(super.folderPath, super.fileName, super.previous, super.params);

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
    super.params,
    this.relativeUrl,
  );

  final String relativeUrl;

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

String getPageName(String fileName) {
  if (fileName.startsWith("+")) {
    //example: "+home_page.dart" -> "HomePage"
    return fileName.replaceAll("+", "").split(".dart")[0].snakeToPascalCase();
  } else if (fileName.startsWith("{")) {
    //example: "{root_shell}.dart" -> "RootShell"
    return fileName.replaceAll("}", "{").split("{")[1].snakeToPascalCase();
  }
  throw Exception("filename needs to start with '+' or '{'");
}

String getRouteName(String fileName) => "${getPageName(fileName)}Route";
