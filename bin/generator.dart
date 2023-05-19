import 'dart:io';
import 'package:path/path.dart';
import 'params.dart';
import 'routes.dart';
import 'extensions/io.dart';

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
    }
  }
  return null;
}

void generateSource(List<Route> routes) {
  final context = BuildContext();
  for (final route in routes) {
    generateRouteSource(context, route);
  }
  final file = File(join("lib", "file_router.dart"));
  file.createSync();
  file.writeAsStringSync(context.source);
}

void generatePage(Route route) {
  final relativePath = joinAll(route.filePath.split("/"));
  final projectName = basename(Directory.current.path);
  final file = File(join(Directory.current.path, "lib", relativePath));
  if (file.containsClass(route.name)) {
    return;
  }
  file.addImport("package:$projectName/file_router.dart");
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
  generatePage(route);
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
    for (final param in route.params) {
      routeBuilder.declarations += "\nfinal ${param.type} ${param.name};";
    }
    final positionalParams = route.params.whereType<UrlParam>();
    final namedParams = route.params.whereType<Optional>();
    final queryParams = route.params.whereType<QueryParam>();
    for (final param in positionalParams) {
      routeBuilder.constructor += "this.${param.name},";
      routeBuilder.fromUrlEncoding +=
          "\nfinal ${param.name} = ${param.type}_converter.fromUrlEncoding(state.params['${param.name}']!);";
      routeBuilder.toUrlEncoding +=
          "\nfinal ${param.name} = ${param.type}_converter.toUrlEncoding(this.${param.name});";
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
        context.addFileImport("${route.folderPath}/${param.fullName}", as: importName);
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

  static $routeName _fromGoRouterState(base.GoRouterState state) {
    ${routeBuilder.fromUrlEncoding}
    return $constString$routeName(${previousRouteName != null ? '$previousRouteName._fromGoRouterState(state), ' : ''}${routeBuilder.instantiation});
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
}
""";
    context.currentIs += """
if (T == $routeName) {
  return base.isAPair('$absoluteUrl', location);
}  
""";
    context.routeTree += """
base.GoRoute(
  path: '${route.relativeUrl}',
  builder: (BuildContext context, base.GoRouterState state) {
    if (state.extra != null) {
      return ${route.name}(base.getRoute<$routeName>(state.extra as base.Route));
    }
    return ${route.name}($routeName._fromGoRouterState(state));
  },
  ${route.children.isEmpty ? '' : 'routes: ['}
""";
  }
  for (final child in route.children) {
    generateRouteSource(context, child);
  }
  if (route.children.isNotEmpty) {
    context.routeTree += "],";
  }
  context.routeTree += "),";
}

void addQueryParamConversions(RouteBuilder routeBuilder, QueryParam param, String routeName) {
  final converter = "${param.type.replaceAll("?", "")}_converter";
  if (param.defaultValue != null) {
    routeBuilder.fromUrlEncoding +=
        "\nfinal ${param.name} = $converter.fromUrlEncoding(state.queryParams['${param.name}'] ?? '${param.defaultValue}');";
  } else if (param.importDefault) {
    routeBuilder.fromUrlEncoding += """
final ${param.type} ${param.name};
if (state.queryParams['${param.name}'] != null) {
  ${param.name} = $converter.fromUrlEncoding(state.queryParams['${param.name}']!);
}
else {
  ${param.name} = ${routeName}_${param.name}.defaultValue;
}
""";
  } else if (param.isRequired) {
    routeBuilder.fromUrlEncoding +=
        "\nfinal ${param.name} = $converter.fromUrlEncoding(state.queryParams['${param.name}']!);";
  } else {
    routeBuilder.fromUrlEncoding += """
final ${param.type} ${param.name};
if (state.queryParams['${param.name}'] != null) {
  ${param.name} = $converter.fromUrlEncoding(state.queryParams['${param.name}']!);
}
else {
  ${param.name} = null;
}""";
  }
  if (param.type.endsWith("?")) {
    routeBuilder.toUrlEncoding += """
if (${param.name} != null) {
  queryParams.add((name: '${param.name}', value: $converter.toUrlEncoding(${param.name}!)));
}
""";
  } else {
    routeBuilder.toUrlEncoding += """
queryParams.add((name: '${param.name}', value: $converter.toUrlEncoding(${param.name})));
""";
  }
}

class RouteBuilder {
  String constructor = "";
  String declarations = "";
  String fromUrlEncoding = "";
  String toUrlEncoding = "";
  String instantiation = "";
}

class BuildContext {
  String routeTree = "";
  String routes = "";
  String imports = "";
  String currentIs = "";

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

const int_converter = base.IntConverter();
const String_converter = base.StringConverter();
const bool_converter = base.BoolConverter();
const double_converter = base.DoubleConverter();

bool currentIs<T extends base.Route>(String location) {
  location = location.split("?")[0];
  $currentIs
  throw Exception("Route detection failure");
}

final routerData = base.FileRouterData(
  currentIs: currentIs,
  routes: [
    $routeTree
  ],
);
""";
  }

  void addFileImport(String path, {String? as}) {
    final projectName = Directory.current.name;
    imports += "\nimport 'package:$projectName/$path'${as != null ? ' as $as' : ''};";
  }
}
