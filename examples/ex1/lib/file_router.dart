///THIS FILE IS GENERATED! DO NOT EDIT IT MANUALLY!///

// ignore_for_file: constant_identifier_names
// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:file_router/file_router.dart' as base;

import 'package:ex1/routes/+error.dart';
import 'package:ex1/types.dart';
import 'package:ex1/routes/{RootShell}/{RootShell}.dart';
import 'package:ex1/routes/{RootShell}/+%/+HomePage.dart';
import 'package:ex1/routes/{RootShell}/+%/1-List{int};numbers%%.dart' as HomePageRoute_numbers;
import 'package:ex1/routes/{RootShell}/+%/+about/+AboutPage.dart';
import 'package:ex1/routes/{RootShell}/+%/+about/+redirect.dart' as aboutPageRedirect;
import 'package:ex1/routes/{RootShell}/+%/+cars/+CarsPage.dart';
import 'package:ex1/routes/{RootShell}/+%/+cars/[int;carId]/+CarPage.dart';

export 'package:file_router/file_router.dart';
export 'package:flutter/material.dart' show BuildContext, Widget, Placeholder, State;

class HomePageRoute implements base.Route {
  const HomePageRoute({
    this.age = 3,
    this.numbers = HomePageRoute_numbers.defaultValue,
    required this.myName,
  }) : previous = null;

  static HomePageRoute fromGoRouterState(base.GoRouterState state, BuildContext context) {
    final storedRoute = base.InheritedRoute.of(context).route;
    if (storedRoute != null) {
      final route = base.getRoute<HomePageRoute>(storedRoute);
      if (route != null) {
        return route;
      }
    }
    throw Exception(
        'The HomePageRoute has required extra parameters. Therefore it can not be instantiated from the location alone.');
  }

  @override
  final base.Route? previous;

  final int age;
  final List<int> numbers;
  final String myName;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);
    queryParams.add((name: 'numbers', value: base.toUrlEncoding<List<int>>(converters, numbers)));

    return base.createLocation('/', queryParams, previous);
  }
}

class AboutPageRoute implements base.Route {
  const AboutPageRoute(
    this.previous, {
    this.parentAge,
    required this.id,
    required this.isAdmin,
    required this.percentage,
    required this.name,
  });

  static AboutPageRoute fromGoRouterState(base.GoRouterState state, BuildContext context) {
    final storedRoute = base.InheritedRoute.of(context).route;
    if (storedRoute != null) {
      final route = base.getRoute<AboutPageRoute>(storedRoute);
      if (route != null) {
        return route;
      }
    }
    final int? parentAge;
    if (state.queryParams['parentAge'] != null) {
      parentAge = base.fromUrlEncoding<int?>(builtInConverters, state.queryParams['parentAge']!);
    } else {
      parentAge = null;
    }
    final id = base.fromUrlEncoding<int>(builtInConverters, state.queryParams['id']!);
    final isAdmin = base.fromUrlEncoding<bool>(builtInConverters, state.queryParams['isAdmin']!);
    final percentage =
        base.fromUrlEncoding<double>(builtInConverters, state.queryParams['percentage']!);
    final name = base.fromUrlEncoding<String>(builtInConverters, state.queryParams['name']!);
    return AboutPageRoute(
      HomePageRoute.fromGoRouterState(state, context),
      parentAge: parentAge,
      id: id,
      isAdmin: isAdmin,
      percentage: percentage,
      name: name,
    );
  }

  @override
  final HomePageRoute previous;

  final int? parentAge;
  final int id;
  final bool isAdmin;
  final double percentage;
  final String name;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);
    if (parentAge != null) {
      queryParams
          .add((name: 'parentAge', value: base.toUrlEncoding<int?>(builtInConverters, parentAge!)));
    }
    queryParams.add((name: 'id', value: base.toUrlEncoding<int>(builtInConverters, id)));
    queryParams.add((name: 'isAdmin', value: base.toUrlEncoding<bool>(builtInConverters, isAdmin)));
    queryParams.add(
        (name: 'percentage', value: base.toUrlEncoding<double>(builtInConverters, percentage)));
    queryParams.add((name: 'name', value: base.toUrlEncoding<String>(builtInConverters, name)));

    return base.createLocation('about', queryParams, previous);
  }

  HomePageRoute get homePageRoute => previous;

  int get age => previous.age;
  List<int> get numbers => previous.numbers;
  String get myName => previous.myName;
}

class CarsPageRoute implements base.Route {
  const CarsPageRoute(
    this.previous,
  );

  static CarsPageRoute fromGoRouterState(base.GoRouterState state, BuildContext context) {
    final storedRoute = base.InheritedRoute.of(context).route;
    if (storedRoute != null) {
      final route = base.getRoute<CarsPageRoute>(storedRoute);
      if (route != null) {
        return route;
      }
    }

    return CarsPageRoute(
      HomePageRoute.fromGoRouterState(state, context),
    );
  }

  @override
  final HomePageRoute previous;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);

    return base.createLocation('cars', queryParams, previous);
  }

  HomePageRoute get homePageRoute => previous;

  int get age => previous.age;
  List<int> get numbers => previous.numbers;
  String get myName => previous.myName;
}

class CarPageRoute implements base.Route {
  const CarPageRoute(
    this.previous,
    this.carId,
  );

  static CarPageRoute fromGoRouterState(base.GoRouterState state, BuildContext context) {
    final storedRoute = base.InheritedRoute.of(context).route;
    if (storedRoute != null) {
      final route = base.getRoute<CarPageRoute>(storedRoute);
      if (route != null) {
        return route;
      }
    }

    final carId = base.fromUrlEncoding<int>(builtInConverters, state.params['carId']!);
    return CarPageRoute(
      CarsPageRoute.fromGoRouterState(state, context),
      carId,
    );
  }

  @override
  final CarsPageRoute previous;

  final int carId;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);

    final carId = base.toUrlEncoding<int>(builtInConverters, this.carId);
    return base.createLocation('$carId', queryParams, previous);
  }

  CarsPageRoute get carsPageRoute => previous;
  HomePageRoute get homePageRoute => previous.previous;

  int get age => previous.previous.age;
  List<int> get numbers => previous.previous.numbers;
  String get myName => previous.previous.myName;
}

const builtInConverters = <base.Converter>[
  base.IntConverter(),
  base.StringConverter(),
  base.BoolConverter(),
  base.DoubleConverter()
];

bool currentRouteIs<T extends base.Route>(String location) {
  location = location.split("?")[0];
  if (T == HomePageRoute) {
    return base.isAPair('/', location);
  }
  if (T == AboutPageRoute) {
    return base.isAPair('/about', location);
  }
  if (T == CarsPageRoute) {
    return base.isAPair('/cars', location);
  }
  if (T == CarPageRoute) {
    return base.isAPair('/cars/:carId', location);
  }

  throw Exception("Route detection failure");
}

base.Route currentRoute(base.GoRouterState state, BuildContext context) {
  if (currentRouteIs<HomePageRoute>(state.location)) {
    return HomePageRoute.fromGoRouterState(state, context);
  }
  if (currentRouteIs<AboutPageRoute>(state.location)) {
    return AboutPageRoute.fromGoRouterState(state, context);
  }
  if (currentRouteIs<CarsPageRoute>(state.location)) {
    return CarsPageRoute.fromGoRouterState(state, context);
  }
  if (currentRouteIs<CarPageRoute>(state.location)) {
    return CarPageRoute.fromGoRouterState(state, context);
  }

  throw Exception("Route retrieval failure");
}

final routerData = base.FileRouterData(
  errorBuilder: base.getErrorBuilder(error),
  currentRouteIs: currentRouteIs,
  currentRoute: currentRoute,
  routes: [
    base.ShellRoute(
      builder: (BuildContext context, base.GoRouterState state, Widget child) {
        final storedRoute = base.InheritedRoute.of(context).route;
        if (storedRoute != null) {
          return RootShell(route: storedRoute, child: child);
        }
        final route = currentRoute(state, context);
        return RootShell(route: route, child: child);
      },
      routes: [
        base.GoRoute(
          path: '/',
          builder: (BuildContext context, base.GoRouterState state) {
            return HomePage(HomePageRoute.fromGoRouterState(state, context));
          },
          routes: [
            base.GoRoute(
              path: 'about',
              builder: (BuildContext context, base.GoRouterState state) {
                return AboutPage(AboutPageRoute.fromGoRouterState(state, context));
              },
              redirect: base.getRedirect<AboutPageRoute>(
                  aboutPageRedirect.redirect, AboutPageRoute.fromGoRouterState),
            ),
            base.GoRoute(
              path: 'cars',
              builder: (BuildContext context, base.GoRouterState state) {
                return CarsPage(CarsPageRoute.fromGoRouterState(state, context));
              },
              routes: [
                base.GoRoute(
                  path: ':carId',
                  builder: (BuildContext context, base.GoRouterState state) {
                    return CarPage(CarPageRoute.fromGoRouterState(state, context));
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
