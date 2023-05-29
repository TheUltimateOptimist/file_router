import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class Route {
  String get location;
  Route? get previous;
}

abstract class RouteMarker {}

class InheritedRoute extends InheritedWidget {
  InheritedRoute(this.route, this.setRoute, {required super.child});

  final Route? route;
  final void Function<R extends Route>(R) setRoute;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static InheritedRoute of(BuildContext context) {
    final inheritedRoute = context.getInheritedWidgetOfExactType<InheritedRoute>();
    if (inheritedRoute == null) {
      throw Exception("InheritedRoute could not be find in the current context");
    }
    return inheritedRoute;
  }
}

class FileRouterProvider extends StatefulWidget {
  const FileRouterProvider(this.initialRoute, {required this.child, super.key});

  final Widget child;
  final Route initialRoute;

  @override
  State<FileRouterProvider> createState() => _FileRouterProviderState();
}

class _FileRouterProviderState extends State<FileRouterProvider> {
  Route? _route;

  @override
  void initState() {
    _route = widget.initialRoute;
    super.initState();
  }

  void setRoute<R extends Route>(R newRoute) {
    setState(() {
      _route = newRoute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedRoute(
      _route,
      setRoute,
      child: widget.child,
    );
  }
}

typedef FileRouterRedirect<T extends Route> = FutureOr<Route?> Function(BuildContext, T);
typedef FromGoRouterState<T extends Route> = T Function(GoRouterState, BuildContext);
GoRouterRedirect getRedirect<T extends Route>(
    FileRouterRedirect<T> fileRouterRedirect, FromGoRouterState<T> fromGoRouterState) {
  return (BuildContext context, GoRouterState state) async {
    final route = await fileRouterRedirect(context, fromGoRouterState(state, context));
    if (route != null) {
      InheritedRoute.of(context).setRoute<Route>(route);
    }
    return route?.location;
  };
}

typedef FileRouterErrorBuilder = Widget Function(BuildContext, Route);
GoRouterWidgetBuilder getErrorBuilder(FileRouterErrorBuilder fileRouterErrorBuilder) {
  return (BuildContext context, GoRouterState state) {
    final route = context.currentRoute(state);
    return fileRouterErrorBuilder(context, route);
  };
}

String createLocation(
    String relativeUrl, List<({String name, String value})> queryParams, Route? previous) {
  String topQueryString =
      queryParams.map((queryParam) => "${queryParam.name}=${queryParam.value}").join("&");
  if (previous == null) {
    final queryString = topQueryString.isNotEmpty ? "?$topQueryString" : "";
    return "$relativeUrl$queryString";
  } else {
    final parentRelativeUrl = previous.location.split("?")[0];
    final parentQueryString = previous.location.substring(parentRelativeUrl.length);
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

R? getRoute<R extends Route>(Route topRoute) {
  Route? route = topRoute;
  while (route != null) {
    if (route is R) {
      return route;
    }
    route = route.previous;
  }
  return route as R?;
}

class FileRouter extends GoRouter {
  FileRouter(
    this.data, {
    required this.initialRoute,
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
        );
  final FileRouterData data;
  final Route initialRoute;

  bool currentRouteIs<T extends Route>() {
    return data.currentRouteIs<T>(location);
  }

  Route currentRoute(GoRouterState state, BuildContext context) {
    return data.currentRoute(state, context);
  }

  void goRoute<R extends Route>(R route, BuildContext context) {
    InheritedRoute.of(context).setRoute(route);
    return go(route.location);
  }

  Future<T?> pushRoute<T extends Object?, R extends Route>(R route, BuildContext context) {
    InheritedRoute.of(context).setRoute(route);
    return push(route.location);
  }

  void pushReplacementRoute<R extends Route>(R route, BuildContext context) {
    InheritedRoute.of(context).setRoute(route);
    return pushReplacement(route.location);
  }

  void replaceRoute<R extends Route>(R route, BuildContext context) {
    InheritedRoute.of(context).setRoute(route);
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

  bool currentRouteIs<T extends Route>() => FileRouter.of(this).currentRouteIs<T>();

  Route currentRoute(GoRouterState state) => FileRouter.of(this).currentRoute(state, this);
}

class FileRouterData {
  const FileRouterData({
    required this.routes,
    required this.currentRouteIs,
    required this.currentRoute,
    this.errorBuilder,
    this.errorPageBuilder,
    this.redirect,
  });
  final List<RouteBase> routes;
  final Widget Function(BuildContext, GoRouterState)? errorBuilder;
  final Page<dynamic> Function(BuildContext, GoRouterState)? errorPageBuilder;
  final FutureOr<String?> Function(BuildContext, GoRouterState)? redirect;
  final bool Function<T extends Route>(String) currentRouteIs;
  final Route Function(GoRouterState, BuildContext) currentRoute;
}

abstract class StatelessPage<T extends Route> extends StatelessWidget {
  const StatelessPage(this.route, {super.key});

  final T route;
}

abstract class StatefulPage<T extends Route> extends StatefulWidget {
  const StatefulPage(this.route, {super.key});

  final T route;
}

abstract class StatelessShell<T extends RouteMarker> extends StatelessWidget {
  const StatelessShell({
    super.key,
    required this.route,
    required this.child,
  });

  final T route;
  final Widget child;
}

abstract class StatefulShell<T extends RouteMarker> extends StatefulWidget {
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

T fromUrlEncoding<T>(List<Converter> customConverters, String data) {
  for (final converter in customConverters) {
    if (converter is Converter<T>) {
      return converter.fromUrlEncoding(data);
    }
  }
  throw Exception("fromUrlEncoding could not find a converter for the type $T");
}

String toUrlEncoding<T>(List<Converter> customConverters, T data) {
  for (final converter in customConverters) {
    if (converter is Converter<T>) {
      return converter.toUrlEncoding(data);
    }
  }
  throw Exception("toUrlEncoding could not find a converter for the type $T");
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
    throw Exception("to convert from string to bool the string must be true or false");
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

bool isAPair(String route, String location) {
  route = route.substring(1);
  location = location.substring(1);
  if (route.isEmpty && location.isEmpty) {
    return true;
  }
  final routeParts = route.split('/');
  final locationParts = location.split('/');
  if (routeParts.length != locationParts.length) {
    return false;
  }
  for (int i = 0; i < locationParts.length; i++) {
    final locationPart = locationParts[i];
    final routePart = routeParts[i];
    if (!routePart.startsWith(":") && routePart != locationPart) {
      return false;
    }
  }
  return true;
}
