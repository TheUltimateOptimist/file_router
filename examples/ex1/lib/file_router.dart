///THIS FILE IS GENERATED! DO NOT EDIT IT MANUALLY!///

// ignore_for_file: constant_identifier_names
// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:file_router/file_router.dart' as base;

import 'package:ex1/routes/{RootShell}/{RootShell}.dart';
import 'package:ex1/routes/{RootShell}/+|/+HomePage.dart';
import 'package:ex1/routes/{RootShell}/+|/+about/+AboutPage.dart';
import 'package:ex1/routes/{RootShell}/+|/+cars/+CarsPage.dart';
import 'package:ex1/routes/{RootShell}/+|/+cars/:int;carId/+CarPage.dart';

export 'package:file_router/file_router.dart';
export 'package:flutter/material.dart' show BuildContext, Widget, Placeholder, State;

class HomePageRoute implements base.Route {
  const HomePageRoute({
    this.age = 3,
  }) : previous = null;

  static HomePageRoute _fromGoRouterState(base.GoRouterState state) {
    return HomePageRoute();
  }

  @override
  final base.Route? previous;

  final int age;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);

    return base.createLocation('/', queryParams, previous);
  }
}

class AboutPageRoute implements base.Route {
  const AboutPageRoute(
    this.previous, {
    required this.id,
    required this.isAdmin,
    this.parentAge,
    required this.percentage,
    required this.name,
  });

  static AboutPageRoute _fromGoRouterState(base.GoRouterState state) {
    final id = int_converter.fromUrlEncoding(state.queryParams['id']!);
    final isAdmin = bool_converter.fromUrlEncoding(state.queryParams['isAdmin']!);
    final int? parentAge;
    if (state.queryParams['parentAge'] != null) {
      parentAge = int_converter.fromUrlEncoding(state.queryParams['parentAge']!);
    } else {
      parentAge = null;
    }
    final percentage = double_converter.fromUrlEncoding(state.queryParams['percentage']!);
    final name = String_converter.fromUrlEncoding(state.queryParams['name']!);
    return AboutPageRoute(
      HomePageRoute._fromGoRouterState(state),
      id: id,
      isAdmin: isAdmin,
      parentAge: parentAge,
      percentage: percentage,
      name: name,
    );
  }

  @override
  final HomePageRoute previous;

  final int id;
  final bool isAdmin;
  final int? parentAge;
  final double percentage;
  final String name;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);
    queryParams.add((name: 'id', value: int_converter.toUrlEncoding(id)));
    queryParams.add((name: 'isAdmin', value: bool_converter.toUrlEncoding(isAdmin)));
    if (parentAge != null) {
      queryParams.add((name: 'parentAge', value: int_converter.toUrlEncoding(parentAge!)));
    }
    queryParams.add((name: 'percentage', value: double_converter.toUrlEncoding(percentage)));
    queryParams.add((name: 'name', value: String_converter.toUrlEncoding(name)));

    return base.createLocation('about', queryParams, previous);
  }
}

class CarsPageRoute implements base.Route {
  const CarsPageRoute(
    this.previous,
  );

  static CarsPageRoute _fromGoRouterState(base.GoRouterState state) {
    return CarsPageRoute(
      HomePageRoute._fromGoRouterState(state),
    );
  }

  @override
  final HomePageRoute previous;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);

    return base.createLocation('cars', queryParams, previous);
  }
}

class CarPageRoute implements base.Route {
  const CarPageRoute(
    this.previous,
    this.carId,
  );

  static CarPageRoute _fromGoRouterState(base.GoRouterState state) {
    final carId = int_converter.fromUrlEncoding(state.params['carId']!);
    return CarPageRoute(
      CarsPageRoute._fromGoRouterState(state),
      carId,
    );
  }

  @override
  final CarsPageRoute previous;

  final int carId;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);

    final carId = int_converter.toUrlEncoding(this.carId);
    return base.createLocation('$carId', queryParams, previous);
  }
}

const int_converter = base.IntConverter();
const String_converter = base.StringConverter();
const bool_converter = base.BoolConverter();
const double_converter = base.DoubleConverter();

bool currentIs<T extends base.Route>(String location) {
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

final routerData = base.FileRouterData(
  currentIs: currentIs,
  routes: [
    base.ShellRoute(
      builder: (BuildContext context, base.GoRouterState state, Widget child) {
        return RootShell(child);
      },
      routes: [
        base.GoRoute(
          path: '/',
          builder: (BuildContext context, base.GoRouterState state) {
            if (state.extra != null) {
              return HomePage(base.getRoute<HomePageRoute>(state.extra as base.Route));
            }
            return HomePage(HomePageRoute._fromGoRouterState(state));
          },
          routes: [
            base.GoRoute(
              path: 'about',
              builder: (BuildContext context, base.GoRouterState state) {
                if (state.extra != null) {
                  return AboutPage(base.getRoute<AboutPageRoute>(state.extra as base.Route));
                }
                return AboutPage(AboutPageRoute._fromGoRouterState(state));
              },
            ),
            base.GoRoute(
              path: 'cars',
              builder: (BuildContext context, base.GoRouterState state) {
                if (state.extra != null) {
                  return CarsPage(base.getRoute<CarsPageRoute>(state.extra as base.Route));
                }
                return CarsPage(CarsPageRoute._fromGoRouterState(state));
              },
              routes: [
                base.GoRoute(
                  path: ':carId',
                  builder: (BuildContext context, base.GoRouterState state) {
                    if (state.extra != null) {
                      return CarPage(base.getRoute<CarPageRoute>(state.extra as base.Route));
                    }
                    return CarPage(CarPageRoute._fromGoRouterState(state));
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
