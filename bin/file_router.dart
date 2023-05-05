import 'dart:io';
import 'package:path/path.dart';

class LibDoesNotExist implements Exception {}

class ShellFileDoesNotExist implements Exception {}

void main(List<String> args) {
  final dir = Directory("lib");
  if (!dir.existsSync()) {
    throw LibDoesNotExist();
  }
  final context = BuildContext.initial();
  createRoute(context, dir);
  final file = File(join(dir.path, "file_router.dart"));
  file.createSync();
  file.writeAsStringSync(context.source);
}

abstract class PathPart {
  String get url;
}

abstract class Param {
  ParamInfo get paramInfo;
}

class UrlParam implements PathPart, Param {
  const UrlParam(this.paramInfo);

  @override
  final ParamInfo paramInfo;

  @override
  String get url {
    return ":${paramInfo.name}";
  }
}

class QueryParam implements Param {
  const QueryParam(this.paramInfo);

  @override
  final ParamInfo paramInfo;
}

class ExtraParam implements Param {
  const ExtraParam(this.paramInfo);

  @override
  final ParamInfo paramInfo;
}

class RawPathPart implements PathPart {
  const RawPathPart(this.url);

  @override
  final String url;
}

class PathParts {
  PathParts()
      : _parts = List.empty(growable: true),
        _danglingParts = List.empty(growable: true);
  final List<PathPart> _parts;
  final List<PathPart> _danglingParts;

  void push(PathPart part) {
    _parts.add(part);
    _danglingParts.add(part);
  }

  PathPart? pop() {
    if (_parts.isEmpty) {
      return null;
    }
    return _parts.removeLast();
  }

  List<UrlParam> urlParams() {
    return _parts.whereType<UrlParam>().toList();
  }

  String get location {
    if (_parts.length == 1) {
      return "/";
    }
    return "/${_parts.skip(1).map((e) => e is UrlParam ? "\$${e.paramInfo.name}Value" : e.url).join("/")}";
  }

  String get goRoutePath {
    final result = _danglingParts.map((e) => e.url).join("/");
    _danglingParts.clear();
    return result;
  }
}

bool maybeAddShell(BuildContext context, Directory dir) {
  final shellDirName = basename(dir.path);
  final shellFile = File(join(dir.path, "{shell}.dart"));
  final shellFileExists = shellFile.existsSync();
  if (!shellDirName.startsWith("{") && !(shellDirName == "lib" && shellFileExists)) {
    return false;
  }
  assert(!shellDirName.startsWith("{") || shellDirName.endsWith("}"));
  if (!shellFileExists) {
    throw ShellFileDoesNotExist();
  }
  final String shellName;
  if (shellDirName == "lib") {
    shellName = "RootShell";
  } else {
    shellName = "${shellDirName.substring(1, shellDirName.length - 1).capitalize()}Shell";
  }
  context.imports += context.getFileImport(shellFile);
  context.router += """
base.ShellRoute(
  builder: (BuildContext context, base.GoRouterState state, Widget child){
    return $shellName(child);
  },
  routes: [
""";
  return true;
}

void createRoute(BuildContext context, Directory dir) {
  final base = basename(dir.path);
  final addedShell = maybeAddShell(context, dir);
  var addedPage = false;
  if (base == "lib") {
    context.pathParts.push(const RawPathPart("/"));
  } else if (base.startsWith("+")) {
    context.pathParts.push(RawPathPart(base.substring(1)));
  } else {
    assert(base.startsWith("[") && base.endsWith("]"));
    final withoutBraces = base.substring(1, base.length - 1);
    context.pathParts.push(UrlParam(extractParamInfo(withoutBraces, base)));
  }
  final file = dir.listSync().whereType<File?>().singleWhere(
        (file) => basename(file!.path).startsWith("+"),
        orElse: () => null,
      );
  if (file != null) {
    createPage(file, context);
    addedPage = true;
  }

  Iterable<Directory> subroutes = dir.listSync().whereType<Directory>().where(
        (directory) => basename(directory.path).startsWith(RegExp(r'[\[\{\+]')),
      );
  for (final route in subroutes) {
    createRoute(context, route);
  }
  context.pathParts.pop();
  if (addedShell || addedPage) {
    context.router = context.router.trimRight();
    if (context.router.endsWith("routes: [")) {
      context.router = context.router.substring(0, context.router.length - 9);
      context.router += "),";
    } else {
      context.router += "],),";
    }
    if (addedShell && addedPage) {
      context.router += "],),";
    }
  }
}

void addParam(RouteBuilder routeBuilder, Param param, String pageName) {
  final type = param.paramInfo.type;
  final name = param.paramInfo.name;
  routeBuilder.definitions += "final $type $name;\n";
  if (param.paramInfo.isRequired && param is! UrlParam) {
    routeBuilder.constructor += "required ";
  }
  routeBuilder.constructor += "this.$name";
  assert(!(param.paramInfo.defaultValue != null && param.paramInfo.importDefault));
  if (param.paramInfo.importDefault) {
    routeBuilder.constructor += " = ${pageName}_$name.defaultValue";
  } else if (param.paramInfo.defaultValue != null) {
    routeBuilder.constructor += " = ${param.paramInfo.defaultValue}";
  }
  routeBuilder.constructor += ", ";
}

class RouteBuilder {
  RouteBuilder();
  String definitions = "";
  String constructor = "";
  String conversions = "";
  String instantiation = "";
  String urlEncoding = "";
  String queryParamPath = "";
}

void convertUrlParam(RouteBuilder routeBuilder, UrlParam param, String pageName) {
  final name = param.paramInfo.name;
  final type = param.paramInfo.type;
  routeBuilder.conversions +=
      "\nfinal $name = ${type}_converter.fromUrlEncoding(state.params['$name']!);";
  routeBuilder.urlEncoding +=
      "\nfinal ${name}Value = ${type}_converter.toUrlEncoding($name);";
  routeBuilder.instantiation += "$name, ";
}

String source_1a(String name, String converter) {
  return "\nfinal $name = $converter.fromUrlEncoding(state.queryParams['$name']!);";
}

String source_1b(String name, String type) {
  return "\nfinal $name = state.extra as $type;";
}

String source_2a(String name, String converter, String defaultValue) {
  return "\nfinal $name = $converter.fromUrlEncoding(state.queryParams['$name'] ?? '$defaultValue');";
}

String source_2b(String name, String type, String converter, String defaultValue) {
  return """
final $type $name;
if (state.extra != null) {
  $name = state.extra;
}
else {
  $name = $converter.fromUrlEncoding('$defaultValue');
}
""";
}

String source_3a(String name, String type, String converter, String pageName) {
  return """
final $type $name;
if (state.queryParams['$name'] != null) {
  $name = $converter.fromUrlEncoding(state.queryParams['$name']!);
}
else {
  $name = ${pageName}_$name.defaultValue;
}
""";
}

String source_3b(String name, String type, String pageName) {
  return """
final $type $name;
if (state.extra != null) {
  $name = state.extra;
}
else {
  $name = ${pageName}_$name.defaultValue;
}
""";
}

String source_4a(String name, String type, String converter) {
  return """
final $type $name;
if (state.queryParams['$name'] != null) {
  $name = $converter.fromUrlEncoding(state.queryParams['$name']!);
}
else {
  $name = null;
}""";
}

String source_4b(String name, String type) {
  return "\nfinal $name = state.extra as $type";
}

void convertQueryExtraParam(RouteBuilder routeBuilder, Param param, String pageName) {
  final name = param.paramInfo.name;
  final type = param.paramInfo.type;
  final converter = "${type.replaceAll("?", "")}_converter";
  final defaultValue = param.paramInfo.defaultValue;
  routeBuilder.instantiation += "$name: $name, ";
  assert(!(defaultValue != null && param.paramInfo.importDefault));
  if (param.paramInfo.isRequired) {
    routeBuilder.conversions +=
        param is QueryParam ? source_1a(name, converter) : source_1b(name, type);
  } else if (defaultValue != null) {
    routeBuilder.conversions += param is QueryParam
        ? source_2a(name, converter, defaultValue)
        : source_2b(name, type, converter, defaultValue);
  } else if (param.paramInfo.importDefault) {
    routeBuilder.conversions += param is QueryParam
        ? source_3a(name, type, converter, pageName)
        : source_3b(name, type, pageName);
  } else {
    routeBuilder.conversions +=
        param is QueryParam ? source_4a(name, type, converter) : source_4b(name, type);
  }
  if (param is ExtraParam) {
    return;
  }
  final value = "${name}Value";
  if (type.endsWith("?")) {
    routeBuilder.urlEncoding += """
if ($name != null) {
  final $value = $converter.toUrlEncoding($name!);
  queryPath += queryPath.isEmpty ? '?$name=\$$value' : '&$name=\$$value';
}
""";
  } else {
    routeBuilder.urlEncoding += """
final $value = $converter.toUrlEncoding($name);
queryPath += queryPath.isEmpty ? '?$name=\$$value' : '&$name=\$$value';
""";
  }
}

void createPage(File page, BuildContext context) {
  final pageName = basename(page.path).replaceAll(".dart", "").substring(1);
  final urlParams = context.pathParts.urlParams();
  final queryParamsWithExtra = extractQueryParams(page.parent);
  final extraParam = extractExtraParam(page.parent);
  if (extraParam != null) {
    queryParamsWithExtra.add(extraParam);
  }
  final routeBuilder = RouteBuilder();
  for (final urlParam in urlParams) {
    addParam(routeBuilder, urlParam, pageName);
    convertUrlParam(routeBuilder, urlParam, pageName);
  }
  if (queryParamsWithExtra.isNotEmpty) {
    routeBuilder.constructor += "{";
  }
  for (final param in queryParamsWithExtra) {
    addParam(routeBuilder, param, pageName);
    convertQueryExtraParam(routeBuilder, param, pageName);
    if (param.paramInfo.importDefault) {
      final file = File(join(page.parent.path, param.paramInfo.fullName));
      final paramName = param.paramInfo.name;
      context.imports += context.getFileImport(file, as: "${pageName}_$paramName");
    }
  }
  if (queryParamsWithExtra.isNotEmpty) {
    routeBuilder.constructor += "}";
  }
  routeBuilder.definitions.trim();
  routeBuilder.conversions.trim();
  final isConst = urlParams.isEmpty && queryParamsWithExtra.isEmpty;
  context.routes += """
class ${pageName}Route implements base.Route {
  const ${pageName}Route(${routeBuilder.constructor});

  ${routeBuilder.definitions}

  @override
  String get location {
    String queryPath = '';
    ${routeBuilder.urlEncoding}
    return '${context.pathParts.location}\$queryPath';
  }

  @override
  Object? get extra => ${extraParam != null ? extraParam.paramInfo.name : 'null'};
}
""";
  context.imports += context.getFileImport(page);
  context.router += """
base.GoRoute(
  path: '${context.pathParts.goRoutePath}',
  builder: (BuildContext context, base.GoRouterState state) {
    ${routeBuilder.conversions}
    ${isConst ? 'const' : 'final'} route = ${pageName}Route(${routeBuilder.instantiation});
    return ${isConst ? 'const ' : ''}$pageName(route);
  },
  routes: [
""";
}

ExtraParam? extractExtraParam(Directory dir) {
  final file = dir.listSync().whereType<File?>().singleWhere(
        (file) => basename(file!.path).startsWith("="),
        orElse: () => null,
      );
  if (file == null) {
    return null;
  }
  final fullName = basename(file.path);
  return ExtraParam(extractParamInfo(fullName.substring(1), fullName));
}

class ParamInfo {
  const ParamInfo(
    this.fullName,
    this.type,
    this.name, {
    this.defaultValue,
    this.importDefault = false,
  });

  final String fullName;
  final String type;
  final String name;
  final String? defaultValue;
  final bool importDefault;

  bool get isRequired {
    return defaultValue == null && !importDefault && !type.endsWith("?");
  }
}

ParamInfo extractParamInfo(String preparedName, String fullName) {
  if (preparedName.endsWith(".dart")) {
    preparedName = preparedName.substring(0, preparedName.length - 5);
  }
  String? defaultValue;
  bool importDefault = false;
  if (preparedName.contains("||")) {
    importDefault = true;
    final parts = preparedName.split("||");
    preparedName = parts[0];
  } else if (preparedName.contains("|")) {
    final parts = preparedName.split("|");
    defaultValue = parts[1];
    preparedName = parts[0];
  }
  final parts = preparedName.split("-");
  return ParamInfo(
    fullName,
    parts[0],
    parts.length > 1 ? parts[1] : parts[0].uncapitalize(),
    importDefault: importDefault,
    defaultValue: defaultValue,
  );
}

List<Param> extractQueryParams(Directory dir) {
  final queryParamFiles = dir.listSync().whereType<File>();
  List<Param> queryParams = List.empty(growable: true);
  for (final file in queryParamFiles) {
    final filename = basename(file.path);
    List<String> numbers = const ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
    bool numberOrMinus = false;
    for (int i = 0; i < filename.length; i++) {
      final isNumber = numbers.contains(filename[i]);
      if (isNumber) {
        numberOrMinus = true;
      } else if (numberOrMinus && filename[i] == "-") {
        queryParams.add(
          QueryParam(extractParamInfo(filename.substring(i + 1), filename)),
        );
      } else {
        break;
      }
    }
  }
  return queryParams;
}

class BuildContext {
  BuildContext(
    this.projectName,
    this.router,
    this.routes,
    this.imports,
    this.pathParts,
  );
  final String projectName;
  String router;
  String routes;
  String imports;
  final PathParts pathParts;

  factory BuildContext.initial() {
    return BuildContext(
      basename(Directory.current.path),
      "",
      "",
      "",
      PathParts(),
    );
  }

  String get source {
    imports.trim();
    return """
///THIS FILE IS GENERATED! DO NOT EDIT IT MANUALLY!///

// ignore_for_file: constant_identifier_names
// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:file_router/file_router.dart' as base;
$imports

export 'package:file_router/file_router.dart';

$routes

const int_converter = base.IntConverter();
const String_converter = base.StringConverter();
const bool_converter = base.BoolConverter();
const double_converter = base.DoubleConverter();

final routerData = base.FileRouterData(routes: [
  $router],);
""";
  }

  String getFileImport(File file, {String? as}) {
    final parts = split(file.path);
    parts.removeAt(0);
    return "\nimport 'package:$projectName/${parts.join("/")}'${as != null ? ' as $as' : ''};";
  }
}

extension StringExtensions on String {
  String transformFirst(String Function(String first) transformer) {
    if (isEmpty) {
      return this;
    }
    return transformer(this[0]) + substring(1);
  }

  String capitalize() => transformFirst((first) => first.toUpperCase());

  String uncapitalize() => transformFirst((first) => first.toLowerCase());

  //String snakeToPascalCase() => split("_").map((word) => word.capitalize()).join("");

  // String snakeToCamelCase() => snakeToPascalCase().uncapitalize();
}
