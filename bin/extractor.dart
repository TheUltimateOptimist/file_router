import 'package:path/path.dart';
import "dart:io";

import 'extensions/io.dart';
import 'extensions/string.dart';
import 'params.dart';
import 'routes.dart';

class RoutesFolderDoesNotExist implements Exception {}

List<Route> extractRoutes() {
  final dir = Directory(join("lib", "routes"));
  if (!dir.existsSync()) {
    throw RoutesFolderDoesNotExist();
  }
  final List<Route> routes = List.empty(growable: true);
  for (final routeDir in extractRouteDirs(dir)) {
    routes.add(extractRoute(routeDir, null));
  }
  return routes;
}

Route extractRoute(Directory dir, Route? previous) {
  final dirName = dir.name;
  final dirPath = split(dir.path).skip(1).join("/"); //skips lib
  assert(dirName.startsWith("+") || dirName.startsWith("[") || dirName.startsWith("{"));
  final Route route;
  if (dirName.startsWith("+") || dirName.startsWith("[")) {
    final relativeUrl = dirName.replaceAll("+", "").split("%").map((part) {
      if (part.startsWith("[")) {
        return ":${parseParamString(part.withoutSurroundingChars()).name}";
      }
      return part;
    }).join("/");
    final params = extractParams(dir);
    final pageFile = dir
        .listSync()
        .whereType<File>()
        .singleWhere((file) => file.name.startsWith("+") && file.name != "+redirect.dart");
    route = RegularRoute(dirPath, pageFile.name, previous, relativeUrl, params);
  } else if (dirName.startsWith("{")) {
    final shellFile =
        dir.listSync().whereType<File>().singleWhere((file) => file.name.startsWith("{"));
    route = ShellRoute(dirPath, shellFile.name, previous);
  } else {
    throw Exception("first letter of dirName has to be +, [ or {");
  }
  for (final routeDir in extractRouteDirs(dir)) {
    route.children.add(extractRoute(routeDir, route));
  }
  return route;
}

List<Directory> extractRouteDirs(Directory dir) {
  return dir
      .listSync()
      .whereType<Directory>()
      .where(
        (dir) => dir.name.startsWith("+") || dir.name.startsWith("[") || dir.name.startsWith("{"),
      )
      .toList();
}

List<Param> extractParams(Directory dir) {
  final dirName = basename(dir.path);
  final List<Param> params = List.empty(growable: true);
  params.addAll(extractUrlParams(dirName));
  for (var file in dir.listSync().whereType<File>()) {
    String fileName = file.name;
    //RegEx matches strings that start with an integer greater than zero followed by a minus
    //e.g. "34-sometext.dart", "1-lol.dart", "12-ahouse"
    if (fileName.startsWith("=") || RegExp(r"\d{1,}-").matchAsPrefix(fileName) != null) {
      final isExtraParam = fileName.startsWith("=");
      bool importDefault = false;
      String? defaultValue;
      if (isExtraParam) {
        fileName = fileName.substring(1);
      } else {
        fileName = fileName.split("-")[1];
      }
      if (fileName.contains("%%")) {
        importDefault = true;
        fileName = fileName.split("%%")[0];
      } else if (fileName.contains("%")) {
        final parts = fileName.split("%");
        defaultValue = parts[1];
        fileName = parts[0];
      }
      var (name: name, type: type) = parseParamString(fileName);
      params.add(
        isExtraParam
            ? ExtraParam(
                file.name,
                name,
                type,
                defaultValue: defaultValue,
                importDefault: importDefault,
              )
            : QueryParam(
                file.name,
                name,
                type,
                defaultValue: defaultValue,
                importDefault: importDefault,
              ),
      );
    }
  }
  return params;
}

List<Param> extractUrlParams(String folderName) {
  final parts = folderName.split("%").where((name) => name.startsWith("["));
  List<Param> params = List.empty(growable: true);
  for (final part in parts) {
    var (name: name, type: type) = parseParamString(part.withoutSurroundingChars());
    params.add(UrlParam(part, name, type));
  }
  return params;
}

({String name, String type}) parseParamString(String input) {
  final parts = input.split(";");
  String type = parts[0];
  //neccessary because windows does not allow "?" as part of filenames
  if (type.endsWith("N")) {
    type = "${type.substring(0, type.length - 1)}?";
  }
  //neccessary because windows does not allow "<", ">" as part of filenames
  type = type.replaceAll("{", "<").replaceAll("}", ">");
  return (
    name: parts.length > 1 ? parts[1] : parts[0].uncapitalize(),
    type: type,
  );
}
