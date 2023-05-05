import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class Route {
  String get location;
  Object? get extra;
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
          initialExtra: initialRoute.extra,
        );

  final FileRouterData data;
  final Route initialRoute;

  void goRoute<R extends Route>(R route) {
    go(route.location, extra: route.extra);
  }

  Future<T?> pushRoute<T extends Object?, R extends Route>(R route) {
    return push(route.location, extra: route.extra);
  }

  void pushReplacementRoute<R extends Route>(R route) {
    return pushReplacement(route.location, extra: route.extra);
  }

  void replaceRoute<R extends Route>(R route) {
    return replace(route.location, extra: route.extra);
  }

  static FileRouter of(BuildContext context) {
    return GoRouter.of(context) as FileRouter;
  }
}

extension FileRouterExtension on BuildContext {
  void goRoute<R extends Route>(R route) {
    FileRouter.of(this).goRoute(route);
  }

  Future<T?> pushRoute<T extends Object?, R extends Route>(R route) {
    return FileRouter.of(this).pushRoute(route);
  }

  void pushReplacementRoute<R extends Route>(R route) {
    FileRouter.of(this).pushReplacementRoute(route);
  }

  void replaceRoute<R extends Route>(R route) {
    FileRouter.of(this).replaceRoute(route);
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

abstract class StatelessShell extends StatelessWidget {
  const StatelessShell(this.child, {super.key});

  final Widget child;
}

abstract class StatefulShell extends StatefulWidget {
  const StatefulShell(this.child, {super.key});

  final Widget child;
}

abstract class Converter<T> {
  String toUrlEncoding(T data);
  T fromUrlEncoding(String data);
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
