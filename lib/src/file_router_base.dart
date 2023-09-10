import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef FromGoRouterState<T extends Route> = T Function(GoRouterState);

abstract class Route {
  String get location;
  Route? get previous;
}

R getRoute<R extends Route>(Route parent) {
  Route? route = parent;
  while (route != null) {
    if (route.runtimeType == R) {
      return route as R;
    }
    route = route.previous;
  }
  throw Exception("The route $R could not be find from the parent $parent");
}

class GlobalRouter {
  GlobalRouter._internal();

  static final GlobalRouter _globalRouter = GlobalRouter._internal();

  factory GlobalRouter() {
    return _globalRouter;
  }

  late final List<RegularRouteData> regularRoutesData;
  Route? route;

  void updateRouteFrom(GoRouterState state) {
    route = findCurrentRoute<Route>(
      state.location,
      (routeData) => routeData.fromGoRouterState(state),
    );
  }

  T getRoute<T extends Route>(GoRouterState state) => _getRoute(T, state) as T;

  Route _getRoute(Type T, GoRouterState state) {
    if (route != null && route.runtimeType == T) {
      return route!;
    }
    updateRouteFrom(state);
    return route!;
  }

  Route currentRoute(GoRouterState state) {
    final constructed =
        findCurrentRoute<Route>(state.location, (foundRouteData) {
      return foundRouteData.fromGoRouterState(state);
    });
    print(route);
    if (route != null &&
        route.runtimeType == constructed.runtimeType &&
        route == constructed) {
      return route!;
    }
    route = constructed;
    return constructed;
  }

  T findCurrentRoute<T>(
      String location, T Function(RegularRouteData) extractor) {
    return _findCurrentRoute<T>(
        regularRoutesData, location.split("?")[0], extractor);
  }

  T _findCurrentRoute<T>(List<RegularRouteData> regularRoutesData,
      String location, T Function(RegularRouteData) extractor) {
    for (final child in regularRoutesData) {
      final childParts = child.path.splitUrl();
      final locationParts = location.splitUrl();
      if (childParts.length > locationParts.length) {
        continue;
      }
      int index = 0;
      for (final childPart in childParts) {
        if (childPart.startsWith(":") || childPart == locationParts[index]) {
          index++;
        } else {
          break;
        }
      }
      if (index == childParts.length &&
          locationParts.length > childParts.length) {
        return _findCurrentRoute<T>(
            child.children,
            locationParts
                .skip(childParts.length)
                .join("/")
                .replaceAll("//", "/"),
            extractor);
      } else if (index == childParts.length) {
        return extractor(child);
      }
    }
    for (final child in regularRoutesData) {
      print(child.toCustomString(""));
    }
    throw Exception(
        "No matching Route Type could be find for $location, extracting $T");
  }
}

extension SplitUrl on String {
  List<String> splitUrl() {
    if (startsWith("/")) {
      final withoutLeading = substring(1);
      if (withoutLeading.isNotEmpty) {
        final result = withoutLeading.split("/");
        result.insert(0, "/");
        return result;
      }
      return ["/"];
    }
    return split("/");
  }
}

class FileShellRoute extends ShellRoute implements ToRegularRouteData {
  FileShellRoute({super.routes, super.builder});

  @override
  void toRegularRouteData(List<RegularRouteData> regularRoutesData) {
    for (final route in routes) {
      (route as ToRegularRouteData).toRegularRouteData(regularRoutesData);
    }
  }
}

abstract class ToRegularRouteData {
  void toRegularRouteData(List<RegularRouteData> routes);
}

class FileRoute<T extends Route> extends GoRoute implements ToRegularRouteData {
  FileRoute({
    required super.path,
    required this.fromGoRouterState,
    required super.builder,
    super.routes,
    super.redirect,
  });

  final FromGoRouterState<T> fromGoRouterState;

  @override
  void toRegularRouteData(List<RegularRouteData> regularRoutesData) {
    final children = List<RegularRouteData>.empty(growable: true);
    for (final route in routes) {
      assert(route is ToRegularRouteData);
      if (route is FileRoute) {
        route.toRegularRouteData(children);
      } else if (route is FileShellRoute) {
        route.toRegularRouteData(regularRoutesData);
      }
    }
    regularRoutesData
        .add(RegularRouteData<T>(path, fromGoRouterState, children: children));
  }
}

class RegularRouteData<T extends Route> {
  const RegularRouteData(this.path, this.fromGoRouterState,
      {this.children = const []});

  Type get type => T;

  final String path;
  final List<RegularRouteData> children;
  final FromGoRouterState<T> fromGoRouterState;

  String toCustomString(String leftSpace) {
    final lines = List<String>.empty(growable: true);
    lines.add("$leftSpace$T:$path:$fromGoRouterState");
    for (final child in children) {
      lines.add(child.toCustomString("    $leftSpace"));
    }
    return lines.join("\n");
  }
}

typedef FileRouterRedirect<T extends Route> = FutureOr<Route?> Function(
    BuildContext, T);

GoRouterRedirect getRedirect<T extends Route>(
    FileRouterRedirect<T> fileRouterRedirect) {
  return (BuildContext context, GoRouterState state) async {
    final newRoute =
        await fileRouterRedirect(context, GlobalRouter().getRoute<T>(state));
    if (newRoute != null) {
      GlobalRouter().route = newRoute;
    }
    return newRoute?.location;
  };
}

typedef FileRouterErrorBuilder = Widget Function(BuildContext, Route);
GoRouterWidgetBuilder getErrorBuilder(
    FileRouterErrorBuilder fileRouterErrorBuilder) {
  return (BuildContext context, GoRouterState state) {
    final route = GlobalRouter().currentRoute(state);
    return fileRouterErrorBuilder(context, route);
  };
}

String createLocation(
    String relativeUrl, List<QueryParam> queryParams, Route? previous) {
  String topQueryString = queryParams
      .map((queryParam) => "${queryParam.name}=${queryParam.value}")
      .join("&");
  if (previous == null) {
    final queryString = topQueryString.isNotEmpty ? "?$topQueryString" : "";
    return "$relativeUrl$queryString";
  } else {
    final parentRelativeUrl = previous.location.split("?")[0];
    final parentQueryString =
        previous.location.substring(parentRelativeUrl.length);
    String queryString = "";
    if (topQueryString.isNotEmpty) {
      queryString = "?$topQueryString${parentQueryString.replaceAll("?", "&")}";
    } else if (parentQueryString.isNotEmpty) {
      queryString = parentQueryString;
    }
    String result = "$parentRelativeUrl/$relativeUrl$queryString";
    if (result.startsWith("//")) {
      result = result.substring(1);
    }
    return result;
  }
}

class FileRouter extends GoRouter {
  FileRouter(
    this.data, {
    required Route initialRoute,
    super.refreshListenable,
    super.redirectLimit = 5,
    super.routerNeglect = false,
    super.observers,
    super.debugLogDiagnostics = false,
    super.restorationScopeId,
  }) : super(
          routes: data.routes,
          errorBuilder: data.errorBuilder,
          errorPageBuilder: data.errorPageBuilder,
          redirect: data.redirect,
          initialLocation: initialRoute.location,
          initialExtra: initialRoute,
        ) {
    GlobalRouter().route = initialRoute;
    final regularRoutesData = List<RegularRouteData>.empty(growable: true);
    for (final route in data.routes) {
      (route as ToRegularRouteData).toRegularRouteData(regularRoutesData);
    }
    GlobalRouter().regularRoutesData = regularRoutesData;
  }

  final FileRouterData data;

  void goRoute<R extends Route>(R route, BuildContext context) {
    GlobalRouter().route = route;
    return go(route.location, extra: route);
  }

  Future<T?> pushRoute<T extends Object?, R extends Route>(
      R route, BuildContext context) {
    GlobalRouter().route = route;
    return push(route.location);
  }

  void pushReplacementRoute<R extends Route>(R route, BuildContext context) {
    GlobalRouter().route = route;
    return pushReplacement(route.location);
  }

  void replaceRoute<R extends Route>(R route, BuildContext context) {
    GlobalRouter().route = route;
    return replace(route.location);
  }

  static FileRouter of(BuildContext context) {
    return GoRouter.of(context) as FileRouter;
  }
}

extension FileRouterExtension on BuildContext {
  void goRoute<R extends Route>(R route) {
    FileRouter.of(this).goRoute(route, this);
  }

  Future<T?> pushRoute<T extends Object?, R extends Route>(R route) {
    return FileRouter.of(this).pushRoute(route, this);
  }

  void pushReplacementRoute<R extends Route>(R route) {
    FileRouter.of(this).pushReplacementRoute(route, this);
  }

  void replaceRoute<R extends Route>(R route) {
    FileRouter.of(this).replaceRoute(route, this);
  }
}

class FileRouterData {
  const FileRouterData({
    required this.routes,
    this.errorBuilder,
    this.errorPageBuilder,
    this.redirect,
  });
  final List<RouteBase> routes;
  final Widget Function(BuildContext, GoRouterState)? errorBuilder;
  final Page<dynamic> Function(BuildContext, GoRouterState)? errorPageBuilder;
  final FutureOr<String?> Function(BuildContext, GoRouterState)? redirect;
}

abstract class StatelessPage<T extends Route> extends StatelessWidget {
  const StatelessPage(this.route, {super.key});

  final T route;
}

abstract class StatefulPage<T extends Route> extends StatefulWidget {
  const StatefulPage(this.route, {super.key});

  final T route;
}

abstract class StatelessShell<T extends Route> extends StatelessWidget {
  const StatelessShell({
    super.key,
    required this.route,
    required this.child,
  });

  final T route;
  final Widget child;
}

abstract class StatefulShell<T extends Route> extends StatefulWidget {
  const StatefulShell({
    super.key,
    required this.route,
    required this.child,
  });

  final T route;
  final Widget child;
}

abstract class Converter<T> {
  String toUrlEncoding(T data);
  T fromUrlEncoding(String data);
}

T fromUrlEncoding<T>(List<Converter> customConverters, String? data,
    {T? defaultValue}) {
  switch ((data, defaultValue)) {
    case (null, null):
      return null as T;
    case (null, var defaultValue?):
      return defaultValue;
    case (var data?, _):
      {
        for (final converter in customConverters) {
          if (converter is Converter<T>) {
            return converter.fromUrlEncoding(data);
          }
        }
        throw Exception(
            "fromUrlEncoding could not find a converter for the type $T");
      }
  }
  throw Exception("the arguments given to fromUrlEncoding are incorrect");
}

class QueryParam {
  const QueryParam(this.name, this.value);

  final String name;
  final String value;
}

String toUrlEncoding<T>(List<Converter> customConverters, T data) {
  for (final converter in customConverters) {
    if (converter is Converter<T>) {
      return converter.toUrlEncoding(data);
    }
  }
  throw Exception("toUrlEncoding could not find a converter for the type $T");
}

void addQueryParam<T>(List<Converter> customConverters, String name, T? data,
    List<QueryParam> queryParams) {
  if (data != null) {
    queryParams.add(QueryParam(name, toUrlEncoding<T>(customConverters, data)));
  }
}

class IntConverter implements Converter<int> {
  const IntConverter();

  @override
  String toUrlEncoding(int data) => data.toString();

  @override
  int fromUrlEncoding(String data) => int.parse(data);
}

class DoubleConverter implements Converter<double> {
  const DoubleConverter();

  @override
  double fromUrlEncoding(String data) => double.parse(data);

  @override
  String toUrlEncoding(double data) => data.toString();
}

class BoolConverter implements Converter<bool> {
  const BoolConverter();

  @override
  bool fromUrlEncoding(String data) {
    if (data == "true") {
      return true;
    } else if (data == "false") {
      return false;
    }
    throw Exception(
        "to convert from string to bool the string must be true or false");
  }

  @override
  String toUrlEncoding(bool data) => data.toString();
}

class StringConverter implements Converter<String> {
  const StringConverter();

  @override
  String fromUrlEncoding(String data) => data;

  @override
  String toUrlEncoding(String data) => data;
}
