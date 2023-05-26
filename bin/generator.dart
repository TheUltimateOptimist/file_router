import 'dart:io';
import 'package:path/path.dart';
import 'extensions/string.dart';
import 'params.dart';
import 'routes.dart';
import 'extensions/io.dart';
import "package:pubspec_parse/pubspec_parse.dart";

List<Param> getAncestorParams(RegularRoute topRoute) {
  List<Param> params = List.empty(growable: true);
  Route? route = topRoute.previous;
  while (route != null) {
    if (route is RegularRoute) {
      params.addAll(route.params);
    }
    route = route.previous;
  }
  return params;
}

String getAbsoluteUrl(RegularRoute topRoute) {
  String url = "";
  Route? route = topRoute;
  while (route != null) {
    if (route is RegularRoute) {
      url = "${route.relativeUrl}/$url";
    }
    route = route.previous;
  }
  url = url.substring(0, url.length - 1);
  if (url.startsWith("//")) {
    url = url.substring(1);
  }
  return url;
}

String? getPreviousRouteName(RegularRoute topRoute) {
  Route? route = topRoute.previous;
  while (route != null) {
    if (route is RegularRoute) {
      return "${route.name}Route";
    } else {
      route = route.previous;
    }
  }
  return null;
}

void generateSource(List<Route> routes) {
  final context = BuildContext.readProjectName();
  addCustomTypes(context);
  for (final route in routes) {
    generateRouteSource(context, route);
  }
  final file = File(join("lib", "file_router.dart"));
  file.createSync();
  file.writeAsStringSync(context.source);
}

// void addErrorPage(BuildContext context) {
//   final file = File(join("lib", "routes", "+error.dart"));
//   if
// }

void generatePage(Route route, BuildContext context) {
  final relativePath = joinAll(route.filePath.split("/"));
  final file = File(join(Directory.current.path, "lib", relativePath));
  if (file.containsClass(route.name)) {
    return;
  }
  file.addImport("package:${context.projectName}/file_router.dart");
  switch (route.runtimeType) {
    case RegularRoute:
      file.insertAfterImports("""
class ${route.name} extends StatelessPage<${route.name}Route> {
  const ${route.name}(super.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// class ${route.name} extends StatefulPage<${route.name}Route> {
//   const ${route.name}(super.route, {super.key});

//   @override
//   State<${route.name}> createState() => _${route.name}State(); 
// }

// class _${route.name}State extends State<${route.name}> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder(); 
//   }
// }
""", topLineSpacing: 1);
    case ShellRoute:
      file.insertAfterImports("""
class ${route.name} extends StatelessShell {
  const ${route.name}(super.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// class ${route.name} extends StatefulShell {
//   const ${route.name}(super.child, {super.key});

//   @override
//   State<${route.name}> createState() => _${route.name}State(); 
// }

// class _${route.name}State extends State<${route.name}> {
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
  generatePage(route, context);
  if (route is ShellRoute) {
    context.routeTree += """
base.ShellRoute(
  builder: (BuildContext context, base.GoRouterState state, Widget child){
    return ${route.name}(child);
  },
  ${route.children.isEmpty ? '' : 'routes: ['}
""";
  } else if (route is RegularRoute) {
    final routeName = "${route.name}Route";
    final previousRouteName = getPreviousRouteName(route);
    final routeBuilder = RouteBuilder();
    addGetters(routeBuilder, route);
    for (final param in route.params) {
      routeBuilder.declarations += "\nfinal ${param.type} ${param.name};";
    }
    final positionalParams = route.params.whereType<UrlParam>();
    final namedParams = route.params.whereType<Optional>();
    final queryParams = route.params.whereType<QueryParam>();
    for (final param in positionalParams) {
      final converters = param.typeBuiltIn ? "builtInConverters" : "converters";
      routeBuilder.constructor += "this.${param.name},";
      routeBuilder.fromUrlEncoding +=
          "\nfinal ${param.name} = base.fromUrlEncoding<${param.type}>($converters, state.params['${param.name}']!);";
      routeBuilder.toUrlEncoding +=
          "\nfinal ${param.name} = base.toUrlEncoding<${param.type}>($converters, this.${param.name});";
      routeBuilder.instantiation += "${param.name}, ";
    }
    if (namedParams.isNotEmpty) {
      routeBuilder.constructor += "{";
    }
    for (final param in namedParams) {
      String defaultAssignment = "";
      if (param.defaultValue != null) {
        String defaultValue = param.defaultValue!;
        if (param.type.startsWith("String")) {
          defaultValue = "'$defaultValue'";
        }
        defaultAssignment = " = $defaultValue";
      } else if (param.importDefault) {
        final importName = "${routeName}_${param.name}";
        context.addFileImport("${route.folderPath}/${param.fullName}",
            additional: " as $importName");
        defaultAssignment = " = $importName.defaultValue";
      } else if (param.isRequired) {
        routeBuilder.constructor += "required ";
      }
      routeBuilder.constructor += "this.${param.name}$defaultAssignment,";
    }
    if (namedParams.isNotEmpty) {
      routeBuilder.constructor += "}";
    }
    for (final queryParam in queryParams) {
      routeBuilder.instantiation += "${queryParam.name}: ${queryParam.name}, ";
      addQueryParamConversions(routeBuilder, queryParam, "${route.name}Route");
    }
    routeBuilder.declarations.trim();
    routeBuilder.fromUrlEncoding.trim();
    final absoluteUrl = getAbsoluteUrl(route);
    String settingPrevious = "";
    if (previousRouteName == null) {
      settingPrevious = " : previous = null";
    }
    String constString = "";
    if (route.previous == null && route.params.isEmpty) {
      constString = "const ";
    }
    context.routes += """
class $routeName implements base.Route {
  const $routeName(${previousRouteName != null ? 'this.previous, ' : ''}${routeBuilder.constructor})$settingPrevious;

  static $routeName fromGoRouterState(base.GoRouterState state) {
    if (state.extra != null) {
      final route = base.getRoute<$routeName>(state.extra as base.Route);
      if (route != null) {
        return route;
      }
    }
    ${routeBuilder.fromUrlEncoding}
    return $constString$routeName(${previousRouteName != null ? '$previousRouteName.fromGoRouterState(state), ' : ''}${routeBuilder.instantiation});
  }

  @override
  final ${previousRouteName ?? 'base.Route?'} previous;
  ${routeBuilder.declarations}

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);
    ${routeBuilder.toUrlEncoding}
    return base.createLocation('${route.relativeUrl.replaceAll(":", "\$")}', queryParams, previous);
  }

  ${routeBuilder.routeGetters}
  ${routeBuilder.fieldGetters}
}
""";
    context.currentRouteIs += """
if (T == $routeName) {
  return base.isAPair('$absoluteUrl', location);
}  
""";

    context.currentRoute += """
if (currentRouteIs<$routeName>(state.location)) {
  return $routeName.fromGoRouterState(state);
}
""";
    context.routeTree += """
base.GoRoute(
  path: '${route.relativeUrl}',
  builder: (BuildContext context, base.GoRouterState state) {

    return ${route.name}($routeName.fromGoRouterState(state));
  },
""";
    addRedirect(context, route);
    if (route.children.isNotEmpty) {
      context.routeTree += "routes: [";
    }
  }
  for (final child in route.children) {
    generateRouteSource(context, child);
  }
  if (route.children.isNotEmpty) {
    context.routeTree += "],";
  }
  context.routeTree += "),";
}

void addRedirect(BuildContext context, RegularRoute route) {
  final file = File(join("lib", joinAll(route.folderPath.split("/")), "+redirect.dart"));
  if (file.existsSync()) {
    final routeName = "${route.name}Route";
    if (file.readAsStringSync().trim().isEmpty) {
      file.writeAsStringSync("""
import 'dart:async';
import 'package:${context.projectName}/file_router.dart';

FutureOr<Route?> redirect(BuildContext context, $routeName route) {
  return null;
}
""");
    }
    final importAs = "${route.name.uncapitalize()}Redirect";
    context.addFileImport("${route.folderPath}/+redirect.dart", additional: " as $importAs");
    context.routeTree +=
        "redirect: base.getRedirect<$routeName>($importAs.redirect, $routeName.fromGoRouterState),";
  }
}

void addCustomTypes(BuildContext context) {
  final file = File(join("lib", "types.dart"));
  if (!file.existsSync()) {
    return;
  }
  context.addFileImport("types.dart");
}

void addGetters(RouteBuilder routeBuilder, RegularRoute route) {
  Route? parentRoute = route.previous;
  String previous = "previous";
  while (parentRoute != null) {
    if (parentRoute is RegularRoute) {
      for (final param in parentRoute.params) {
        routeBuilder.fieldGetters += """
${param.type} get ${param.name} => $previous.${param.name}; 
""";
      }
      routeBuilder.routeGetters += """
${parentRoute.name}Route get ${parentRoute.name.uncapitalize()}Route => $previous;
""";
    }
    parentRoute = parentRoute.previous;
    previous += ".previous";
  }
}

void addQueryParamConversions(RouteBuilder routeBuilder, QueryParam param, String routeName) {
  final converters = param.typeBuiltIn ? "builtInConverters" : "converters";
  if (param.defaultValue != null) {
    routeBuilder.fromUrlEncoding +=
        "\nfinal ${param.name} = base.fromUrlEncoding<${param.type}>($converters, state.queryParams['${param.name}'] ?? '${param.defaultValue}');";
  } else if (param.importDefault) {
    routeBuilder.fromUrlEncoding += """
final ${param.type} ${param.name};
if (state.queryParams['${param.name}'] != null) {
  ${param.name} = base.fromUrlEncoding<${param.type}>($converters, state.queryParams['${param.name}']!);
}
else {
  ${param.name} = ${routeName}_${param.name}.defaultValue;
}
""";
  } else if (param.isRequired) {
    routeBuilder.fromUrlEncoding +=
        "\nfinal ${param.name} = base.fromUrlEncoding<${param.type}>($converters, state.queryParams['${param.name}']!);";
  } else {
    routeBuilder.fromUrlEncoding += """
final ${param.type} ${param.name};
if (state.queryParams['${param.name}'] != null) {
  ${param.name} = base.fromUrlEncoding<${param.type}>($converters, state.queryParams['${param.name}']!);
}
else {
  ${param.name} = null;
}""";
  }
  if (param.type.endsWith("?")) {
    routeBuilder.toUrlEncoding += """
if (${param.name} != null) {
  queryParams.add((name: '${param.name}', value: base.toUrlEncoding<${param.type}>($converters, ${param.name}!)));
}
""";
  } else {
    routeBuilder.toUrlEncoding += """
queryParams.add((name: '${param.name}', value: base.toUrlEncoding<${param.type}>($converters, ${param.name})));
""";
  }
}

class RouteBuilder {
  String constructor = "";
  String declarations = "";
  String fromUrlEncoding = "";
  String toUrlEncoding = "";
  String instantiation = "";
  String fieldGetters = "";
  String routeGetters = "";
}

class BuildContext {
  BuildContext(this.projectName);

  String routeTree = "";
  String routes = "";
  String imports = "";
  String currentRouteIs = "";
  String currentRoute = "";
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

bool currentRouteIs<T extends base.Route>(String location) {
  location = location.split("?")[0];
  $currentRouteIs
  throw Exception("Route detection failure");
}  

base.Route currentRoute(base.GoRouterState state) {
  $currentRoute
  throw Exception("Route retrieval failure");
}

final routerData = base.FileRouterData(
  currentRouteIs: currentRouteIs,
  currentRoute: currentRoute,
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
