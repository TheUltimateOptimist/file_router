import 'dart:io';
import 'package:path/path.dart';
import 'extensions/string.dart';
import 'params.dart';
import 'routes.dart';
import 'extensions/io.dart';
import "package:pubspec_parse/pubspec_parse.dart";

void generateSource(List<Route> routes) {
  final context = BuildContext.readProjectName();
  addErrorBuilder(context);
  addCustomTypes(context);
  for (final route in routes) {
    generateRouteSource(context, route);
  }
  final file = File(join("lib", "file_router.dart"));
  file.createSync();
  file.writeAsStringSync(context.source);
}

void addErrorBuilder(BuildContext context) {
  final file = File(join("lib", "routes", "+error.dart"));
  if (file.existsSync()) {
    if (file.readAsStringSync().trim().isEmpty) {
      file.writeAsStringSync("""
import 'package:${context.projectName}/file_router.dart';

Widget error(BuildContext context, Route route) {
  return const Placeholder();
}
""");
    }
    context.addFileImport("routes/+error.dart");
    context.errorPageBuilder = "errorBuilder: base.getErrorBuilder(error),";
  } else {
    context.errorPageBuilder = "errorBuilder: null,";
  }
}

void generatePage(BuildContext context, Route route) {
  final relativePath = joinAll(route.filePath.split("/"));
  final file = File(join(Directory.current.path, "lib", relativePath));
  if (file.containsClass(route.pageName)) {
    return;
  }
  file.addImport("package:${context.projectName}/file_router.dart");
  switch (route.runtimeType) {
    case RegularRoute:
      file.insertAfterImports("""
class ${route.pageName} extends StatelessPage<${route.routeName}> {
  const ${route.pageName}(super.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// class ${route.pageName} extends StatefulPage<${route.routeName}> {
//   const ${route.pageName}(super.route, {super.key});

//   @override
//   State<${route.pageName}> createState() => _${route.pageName}State(); 
// }

// class _${route.pageName}State extends State<${route.pageName}> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder(); 
//   }
// }
""", topLineSpacing: 1);
    case ShellRoute:
      file.insertAfterImports("""
class ${route.pageName} extends StatelessShell<${getShellRouteType(route as ShellRoute)}> {
  const ${route.pageName}({super.key, required super.route, required super.child,});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// class ${route.pageName} extends StatefulShell<${getShellRouteType(route)}> {
//   const ${route.pageName}({super.key, required super.route, required super.child,});

//   @override
//   State<${route.pageName}> createState() => _${route.pageName}State(); 
// }

// class _${route.pageName}State extends State<${route.pageName}> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder(); 
//   }
// }
""", topLineSpacing: 1);
  }
}

void generateRouteSource(BuildContext context, Route route) {
  context.addFileImport(route.filePath);
  generatePage(context, route);
  addParamDefaultValueImports(context, route);
  switch (route) {
    case RegularRoute():
      addRegularRoute(context, route);
      addRedirect(context, route);
    case ShellRoute():
      addShellRoute(context, route);
  }
  for (final route in route.children) {
    generateRouteSource(context, route);
  }
  if (route.children.isNotEmpty) {
    context.routeTree += "],";
  }
  context.routeTree += "),";
}

void addRedirect(BuildContext context, RegularRoute route) {
  final file = File(join("lib", joinAll(route.folderPath.split("/")), "+redirect.dart"));
  if (file.existsSync()) {
    if (file.readAsStringSync().trim().isEmpty) {
      file.writeAsStringSync("""
import 'dart:async';
import 'package:${context.projectName}/file_router.dart';

FutureOr<Route?> redirect(BuildContext context, ${route.routeName} route) {
  return null;
}
""");
    }
    final importAs = "${route.routeName.uncapitalize()}Redirect";
    context.addFileImport("${route.folderPath}/+redirect.dart", additional: " as $importAs");
    context.routeTree += "redirect: base.getRedirect<${route.routeName}>($importAs.redirect),";
  }
}

String getParentType(Route route) {
  if (route.previous case final previous?) {
    return previous.routeName;
  }
  return "base.Route";
}

String getShellRouteType(ShellRoute route) {
  if (route.children.length == 1 && route.children.first is RegularRoute) {
    return route.children.first.routeName;
  }
  return route.routeName;
}

RegularRoute? getParentRegularRoute(Route route) {
  Route? parentRoute = route.previous;
  while (parentRoute != null) {
    if (parentRoute is RegularRoute) {
      return parentRoute;
    }
    parentRoute = parentRoute.previous;
  }
  return null;
}

String getAbstractGetters(List<Param> params) {
  return params.map((param) => "${param.type} get ${param.name};").join("\n");
}

void addShellRoute(BuildContext context, ShellRoute route) {
  context.routeTree += """
base.FileShellRoute(
  builder: (BuildContext context, base.GoRouterState state, Widget child){
    final route = base.GlobalRouter().currentRoute(state) as ${getShellRouteType(route)};
    return ${route.pageName}(route: route, child: child);
  },
  ${route.children.isEmpty ? '' : 'routes: ['}
""";

  context.routes += """
sealed class ${route.routeName} implements ${getParentType(route)} {
  ${getAbstractGetters(route.params)}
}
""";
}

void addRegularRoute(BuildContext context, RegularRoute route) {
  final params = getRouteParams(route);
  final relativeUrl = "'${route.relativeUrl}'";
  final parentRegularRoute = getParentRegularRoute(route);
  final ({String constructor, String definition}) previous;
  if (parentRegularRoute == null) {
    previous = (constructor: "", definition: "@override\nbase.Route? get previous => null;");
  } else {
    previous = (constructor: "this.previous, ", definition: "@override\nfinal ${parentRegularRoute.routeName} previous;");
  }
  context.routeTree += """
base.FileRoute<${route.routeName}>(
  fromGoRouterState: ${route.routeName}.fromGoRouterState,
  path: $relativeUrl,
  builder: (BuildContext context, base.GoRouterState state) {
    return ${route.pageName}(base.GlobalRouter().getRoute<${route.routeName}>(state));
  },
  ${route.children.isEmpty ? '' : 'routes: ['}
""";
  context.routes += """
class ${route.routeName} implements ${getParentType(route)} {
  const ${route.routeName}(${previous.constructor}${getParamDeclarations(params)});

  ${previous.definition}
  ${getParamDefinitions(params)}

  ${getFromGoRouterState(route)}

  @override
  String get location {
    final List<base.QueryParam> queryParams = List.empty(growable: true);
    ${getToUrlEncoding(params)}
    return base.createLocation(${relativeUrl.replaceAll(":", "\$")}, queryParams, previous);
  }

  ${route.routeName} get ${route.routeName.uncapitalize()} => this;
  ${getRouteAndFieldGetters(route)}
}
""";
}

List<Param> getRouteParams(RegularRoute route) {
  final params = route.params;
  var parentRoute = route.previous;
  while (parentRoute != null && parentRoute is! RegularRoute) {
    params.addAll(parentRoute.params);
    parentRoute = parentRoute.previous;
  }
  return params;
}

String getParamDefinitions(List<Param> params) {
  return params.map((param) {
    return "final ${param.type} ${param.name};";
  }).join("\n");
}

String getParamDeclarations(List<Param> params) {
  final positionals = params.whereType<UrlParam>();
  final optionals = params.whereType<Optional>();
  final positionalString = positionals.map((param) => "this.${param.name},").join(" ");
  final optionalString = optionals
      .map((param) {
        if (param.type.endsWith("?")) {
          return "this.${param.name},";
        }
        if (param.isRequired) {
          return "required this.${param.name},";
        }
        return "this.${param.name} = ${param.defaultValue!},";
      })
      .join(" ")
      .surroundWith("{", right: "}", ifEmpty: false);
  return "$positionalString$optionalString";
}

String getParamInstantiations(List<Param> params) {
  final positionals = params.whereType<UrlParam>();
  final optionals = params.whereType<Optional>();
  final positionalString = positionals.map((param) => "${param.name},").join(" ");
  final optionalString = optionals.map((param) => "${param.name}: ${param.name},").join(" ");
  return "$positionalString$optionalString";
}

String getFromGoRouterState(RegularRoute route) {
  if (route.params.any((param) => param is ExtraParam && param.isRequired)) {
    return """
static ${route.routeName} fromGoRouterState(base.GoRouterState state) {
  throw Exception('The ${route.routeName} has required extra parameters. Therefore it can not be instantiated from the location alone.');
}
""";
  }
  final parentRoute = getParentRegularRoute(route);
  final params = route.params.where((param) => !(param is ExtraParam && param.isRequired)).toList();
  String parentInstantiation = "";
  if (parentRoute != null) {
    parentInstantiation = "${parentRoute.routeName}.fromGoRouterState(state), ";
  }
  return """
static ${route.routeName} fromGoRouterState(base.GoRouterState state) {
  ${getFromUrlEncoding(route.params)}
  return ${route.routeName}($parentInstantiation${getParamInstantiations(params)});
}
""";
}

void addCustomTypes(BuildContext context) {
  final file = File(join("lib", "types.dart"));
  if (!file.existsSync()) {
    return;
  }
  context.addFileImport("types.dart");
}

String getRouteAndFieldGetters(RegularRoute route) {
  Route? parentRoute = route.previous;
  String previous = "previous";
  List<String> lines = List.empty(growable: true);
  while (parentRoute != null) {
    if (parentRoute is RegularRoute) {
      lines.add("${parentRoute.routeName} get ${parentRoute.routeName.uncapitalize()} => $previous;");
      for (final param in parentRoute.params) {
        lines.add("@override\n${param.type} get ${param.name} => $previous.${param.name};");
      }
    }
    parentRoute = parentRoute.previous;
    previous += ".previous";
  }
  return lines.join("\n");
}

String getConvertersName(Param param) {
  return param.typeBuiltIn ? "builtInConverters" : "converters";
}

String getToUrlEncoding(List<Param> params) {
  List<String> lines = List.empty(growable: true);
  for (final param in params) {
    if (param is UrlParam) {
      lines.add("final ${param.name} = base.toUrlEncoding<${param.type}>(${getConvertersName(param)}, this.${param.name});");
    } else if (param is QueryParam) {
      lines.add("base.addQueryParam<${param.type}>(${getConvertersName(param)}, '${param.name}', ${param.name}, queryParams);");
    }
  }
  return lines.join("\n");
}

void addParamDefaultValueImports(BuildContext context, Route route) {
  for (final param in route.params) {
    if (param is Optional && param.importDefaultAs != null) {
      context.addFileImport("${route.folderPath}/${param.fullName}", additional: " as ${param.importDefaultAs}");
    }
  }
}

String getFromUrlEncoding(List<Param> params) {
  List<String> lines = List.empty(growable: true);
  for (final param in params) {
    if (param is UrlParam) {
      lines.add("final ${param.name} = base.fromUrlEncoding<${param.type}>(${getConvertersName(param)}, state.params['${param.name}']);");
    } else if (param is QueryParam) {
      String defaultValue = param.defaultValue ?? "null";
      lines.add("final ${param.name} = base.fromUrlEncoding<${param.type}>(${getConvertersName(param)}, state.queryParams['${param.name}'], defaultValue: $defaultValue);");
    }
  }
  return lines.join("\n");
}

class BuildContext {
  BuildContext(this.projectName);

  String routeTree = "";
  String routes = "";
  String imports = "";
  String errorPageBuilder = "";
  final String projectName;

  factory BuildContext.readProjectName() {
    final yaml = File("pubspec.yaml").readAsStringSync();
    final pubspec = Pubspec.parse(yaml);
    return BuildContext(pubspec.name);
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
export 'package:flutter/material.dart' show BuildContext, Widget, Placeholder, State;

$routes

const builtInConverters = <base.Converter>[base.IntConverter(), base.StringConverter(), base.BoolConverter(), base.DoubleConverter()];

final routerData = base.FileRouterData(
  $errorPageBuilder
  routes: [
    $routeTree
  ],
);
""";
  }

  void addFileImport(String path, {String additional = ""}) {
    imports += "\nimport 'package:$projectName/$path'$additional;";
  }
}
