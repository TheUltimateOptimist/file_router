///THIS FILE IS GENERATED! DO NOT EDIT IT MANUALLY!///

// ignore_for_file: constant_identifier_names
// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:file_router/file_router.dart' as base;

import 'package:ex1/types.dart';
import 'package:ex1/routes/{RootShell}/{RootShell}.dart';
import 'package:ex1/routes/{RootShell}/+%/+HomePage.dart';
import 'package:ex1/routes/{RootShell}/+%/1-IntList;numbers%%.dart' as HomePageRoute_numbers;
import 'package:ex1/routes/{RootShell}/+%/+about/+AboutPage.dart';
import 'package:ex1/routes/{RootShell}/+%/+cars/+CarsPage.dart';
import 'package:ex1/routes/{RootShell}/+%/+cars/[int;carId]/+CarPage.dart';

export 'package:file_router/file_router.dart';
export 'package:flutter/material.dart' show BuildContext, Widget, Placeholder, State;

class HomePageRoute implements base.Route {
  const HomePageRoute({
    this.numbers = HomePageRoute_numbers.defaultValue,
    this.age = 3,
  }) : previous = null;

  static HomePageRoute _fromGoRouterState(base.GoRouterState state) {
    final IntList numbers;
    if (state.queryParams['numbers'] != null) {
      numbers = base.fromUrlEncoding<IntList>(converters, state.queryParams['numbers']!);
    } else {
      numbers = HomePageRoute_numbers.defaultValue;
    }

    return HomePageRoute(
      numbers: numbers,
    );
  }

  @override
  final base.Route? previous;

  final IntList numbers;
  final int age;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);
    queryParams.add((name: 'numbers', value: base.toUrlEncoding<IntList>(converters, numbers)));

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
    final id = base.fromUrlEncoding<int>(builtInConverters, state.queryParams['id']!);
    final isAdmin = base.fromUrlEncoding<bool>(builtInConverters, state.queryParams['isAdmin']!);
    final int? parentAge;
    if (state.queryParams['parentAge'] != null) {
      parentAge = base.fromUrlEncoding<int?>(builtInConverters, state.queryParams['parentAge']!);
    } else {
      parentAge = null;
    }
    final percentage =
        base.fromUrlEncoding<double>(builtInConverters, state.queryParams['percentage']!);
    final name = base.fromUrlEncoding<String>(builtInConverters, state.queryParams['name']!);
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
    queryParams.add((name: 'id', value: base.toUrlEncoding<int>(builtInConverters, id)));
    queryParams.add((name: 'isAdmin', value: base.toUrlEncoding<bool>(builtInConverters, isAdmin)));
    if (parentAge != null) {
      queryParams
          .add((name: 'parentAge', value: base.toUrlEncoding<int?>(builtInConverters, parentAge!)));
    }
    queryParams.add(
        (name: 'percentage', value: base.toUrlEncoding<double>(builtInConverters, percentage)));
    queryParams.add((name: 'name', value: base.toUrlEncoding<String>(builtInConverters, name)));

    return base.createLocation('about', queryParams, previous);
  }

  HomePageRoute get homePageRoute => previous;

  IntList get numbers => previous.numbers;
  int get age => previous.age;
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

  HomePageRoute get homePageRoute => previous;

  IntList get numbers => previous.numbers;
  int get age => previous.age;
}

class CarPageRoute implements base.Route {
  const CarPageRoute(
    this.previous,
    this.carId,
  );

  static CarPageRoute _fromGoRouterState(base.GoRouterState state) {
    final carId = base.fromUrlEncoding<int>(builtInConverters, state.params['carId']!);
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

    final carId = base.toUrlEncoding<int>(builtInConverters, this.carId);
    return base.createLocation('$carId', queryParams, previous);
  }

  CarsPageRoute get carsPageRoute => previous;
  HomePageRoute get homePageRoute => previous.previous;

  IntList get numbers => previous.previous.numbers;
  int get age => previous.previous.age;
}

const builtInConverters = <base.Converter>[
  base.IntConverter(),
  base.StringConverter(),
  base.BoolConverter(),
  base.DoubleConverter()
];

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
              final route = base.getRoute<HomePageRoute>(state.extra as base.Route);
              if (route != null) {
                return HomePage(route);
              }
            }
            return HomePage(HomePageRoute._fromGoRouterState(state));
          },
          routes: [
            base.GoRoute(
              path: 'about',
              builder: (BuildContext context, base.GoRouterState state) {
                if (state.extra != null) {
                  final route = base.getRoute<AboutPageRoute>(state.extra as base.Route);
                  if (route != null) {
                    return AboutPage(route);
                  }
                }
                return AboutPage(AboutPageRoute._fromGoRouterState(state));
              },
            ),
            base.GoRoute(
              path: 'cars',
              builder: (BuildContext context, base.GoRouterState state) {
                if (state.extra != null) {
                  final route = base.getRoute<CarsPageRoute>(state.extra as base.Route);
                  if (route != null) {
                    return CarsPage(route);
                  }
                }
                return CarsPage(CarsPageRoute._fromGoRouterState(state));
              },
              routes: [
                base.GoRoute(
                  path: ':carId',
                  builder: (BuildContext context, base.GoRouterState state) {
                    if (state.extra != null) {
                      final route = base.getRoute<CarPageRoute>(state.extra as base.Route);
                      if (route != null) {
                        return CarPage(route);
                      }
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
