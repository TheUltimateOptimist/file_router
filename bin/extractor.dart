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
    final pageFile = dir.listSync().whereType<File>().singleWhere((file) => file.name.startsWith("+") && file.name != "+redirect.dart");
    final routeName = getRouteName(pageFile.name);
    final params = extractUrlParams(dir.name) + extractQueryParams(dir, routeName) + extractExtraParams(dir, routeName);
    final relativeUrl = dirName.replaceAll("+", "").split("%").map((part) {
      if (part.startsWith("[")) {
        return ":${parseParamString(part.withoutSurroundingChars(), routeName).name}";
      }
      return part;
    }).join("/");
    route = RegularRoute(dirPath, pageFile.name, previous, params, relativeUrl);
  } else if (dirName.startsWith("{")) {
    final shellFile = dir.listSync().whereType<File>().singleWhere((file) => file.name.startsWith("{"));
    final routeName = getRouteName(shellFile.name);
    final params = extractQueryParams(dir, routeName) + extractExtraParams(dir, routeName);
    route = ShellRoute(dirPath, shellFile.name, previous, params);
  } else {
    throw Exception("first letter of dirName has to be +, [ or {");
  }
  for (final routeDir in extractRouteDirs(dir)) {
    route.children.add(extractRoute(routeDir, route));
  }
  return route;
}

List<Directory> extractRouteDirs(Directory dir) {
  return dir.listSync().whereType<Directory>().where((dir) => dir.name.startsWith("+") || dir.name.startsWith("[") || dir.name.startsWith("{")).toList();
}

List<Param> extractExtraParams(Directory dir, String routeName) {
  return dir.listSync().whereType<File>().where((file) => file.name.startsWith("=")).map<Param>((file) {
    final parseResult = parseParamString(file.name.substring(1), routeName);
    return ExtraParam(
      file.name,
      parseResult.name,
      parseResult.type,
      defaultValue: parseResult.defaultValue,
      importDefaultAs: parseResult.importDefaultAs,
    );
  }).toList();
}

List<Param> extractQueryParams(Directory dir, String routeName) {
  //RegEx matches strings that start with an integer greater than zero followed by a minus
  //e.g. "34-sometext.dart", "1-lol.dart", "12-ahouse"
  return dir.listSync().whereType<File>().where((file) => RegExp(r"\d{1,}-").matchAsPrefix(file.name) != null).map<Param>((file) {
    final parseResult = parseParamString(file.name.split("-")[1], routeName);
    return QueryParam(
      file.name,
      parseResult.name,
      parseResult.type,
      defaultValue: parseResult.defaultValue,
      importDefaultAs: parseResult.importDefaultAs,
    );
  }).toList();
}

List<Param> extractUrlParams(String folderName) {
  return folderName.split("%").where((name) => name.startsWith("[")).map<Param>((paramString) {
    final parseResult = parseParamString(paramString.withoutSurroundingChars(), "");
    return UrlParam(paramString, parseResult.name, parseResult.type);
  }).toList();
}

typedef ParamParseResult = ({String type, String name, String? defaultValue, String? importDefaultAs});

ParamParseResult parseParamString(String input, String routeName) {
  String? defaultValue;
  bool importDefault = false;
  if (input.contains("%%")) {
    importDefault = true;
    input = input.split("%%")[0];
  } else if (input.contains("%")) {
    final parts = input.split("%");
    defaultValue = parts[1];
    input = parts[0];
  }
  final parts = input.split(";");
  String type = parts[0];
  String name = parts.length > 1 ? parts[1] : parts[0].uncapitalize();

  //neccessary because windows does not allow "?" as part of filenames
  if (type.endsWith("N")) {
    type = "${type.substring(0, type.length - 1)}?";
  }

  //neccessary because windows does not allow "<", ">" as part of filenames
  type = type.replaceAll("{", "<").replaceAll("}", ">");

  if (type.startsWith("String") && defaultValue != null) {
    defaultValue = "'$defaultValue'";
  }

  return (
    type: type,
    name: name,
    defaultValue: importDefault ? "${routeName}_$name.defaultValue" : defaultValue,
    importDefaultAs: importDefault ? "${routeName}_$name" : null,
  );
}
