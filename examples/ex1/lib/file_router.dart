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
import 'package:ex1/routes/{RootShell}/+%/+about/+redirect.dart' as aboutPageRouteRedirect;
import 'package:ex1/routes/{RootShell}/+%/+cars/+CarsPage.dart';
import 'package:ex1/routes/{RootShell}/+%/+cars/[int;carId]/+CarPage.dart';

export 'package:file_router/file_router.dart';
export 'package:flutter/material.dart' show BuildContext, Widget, Placeholder, State;

sealed class RootShellRoute implements base.Route {}

class HomePageRoute implements RootShellRoute {
  const HomePageRoute({
    this.numbers = HomePageRoute_numbers.defaultValue,
    this.age = 3,
    required this.myName,
  });

  @override
  base.Route? get previous => null;
  final List<int> numbers;
  final int age;
  final String myName;

  static HomePageRoute fromGoRouterState(base.GoRouterState state) {
    throw Exception('The HomePageRoute has required extra parameters. Therefore it can not be instantiated from the location alone.');
  }

  @override
  String get location {
    final List<base.QueryParam> queryParams = List.empty(growable: true);
    base.addQueryParam<List<int>>(converters, 'numbers', numbers, queryParams);
    return base.createLocation('/', queryParams, previous);
  }
}

class AboutPageRoute implements HomePageRoute {
  const AboutPageRoute(
    this.previous, {
    this.parentAge,
    required this.id,
    required this.isAdmin,
    required this.percentage,
    required this.name,
  });

  @override
  final HomePageRoute previous;
  final int? parentAge;
  final int id;
  final bool isAdmin;
  final double percentage;
  final String name;

  static AboutPageRoute fromGoRouterState(base.GoRouterState state) {
    final parentAge = base.fromUrlEncoding<int?>(builtInConverters, state.queryParams['parentAge'], defaultValue: null);
    final id = base.fromUrlEncoding<int>(builtInConverters, state.queryParams['id'], defaultValue: null);
    final isAdmin = base.fromUrlEncoding<bool>(builtInConverters, state.queryParams['isAdmin'], defaultValue: null);
    final percentage = base.fromUrlEncoding<double>(builtInConverters, state.queryParams['percentage'], defaultValue: null);
    final name = base.fromUrlEncoding<String>(builtInConverters, state.queryParams['name'], defaultValue: null);
    return AboutPageRoute(
      HomePageRoute.fromGoRouterState(state),
      parentAge: parentAge,
      id: id,
      isAdmin: isAdmin,
      percentage: percentage,
      name: name,
    );
  }

  @override
  String get location {
    final List<base.QueryParam> queryParams = List.empty(growable: true);
    base.addQueryParam<int?>(builtInConverters, 'parentAge', parentAge, queryParams);
    base.addQueryParam<int>(builtInConverters, 'id', id, queryParams);
    base.addQueryParam<bool>(builtInConverters, 'isAdmin', isAdmin, queryParams);
    base.addQueryParam<double>(builtInConverters, 'percentage', percentage, queryParams);
    base.addQueryParam<String>(builtInConverters, 'name', name, queryParams);
    return base.createLocation('about', queryParams, previous);
  }

  HomePageRoute get homePageRoute => previous;
  @override
  List<int> get numbers => previous.numbers;
  @override
  int get age => previous.age;
  @override
  String get myName => previous.myName;
}

class CarsPageRoute implements HomePageRoute {
  const CarsPageRoute(
    this.previous,
  );

  @override
  final HomePageRoute previous;

  static CarsPageRoute fromGoRouterState(base.GoRouterState state) {
    return CarsPageRoute(
      HomePageRoute.fromGoRouterState(state),
    );
  }

  @override
  String get location {
    final List<base.QueryParam> queryParams = List.empty(growable: true);

    return base.createLocation('cars', queryParams, previous);
  }

  HomePageRoute get homePageRoute => previous;
  @override
  List<int> get numbers => previous.numbers;
  @override
  int get age => previous.age;
  @override
  String get myName => previous.myName;
}

class CarPageRoute implements CarsPageRoute {
  const CarPageRoute(
    this.previous,
    this.carId,
  );

  @override
  final CarsPageRoute previous;
  final int carId;

  static CarPageRoute fromGoRouterState(base.GoRouterState state) {
    final carId = base.fromUrlEncoding<int>(builtInConverters, state.params['carId']);
    return CarPageRoute(
      CarsPageRoute.fromGoRouterState(state),
      carId,
    );
  }

  @override
  String get location {
    final List<base.QueryParam> queryParams = List.empty(growable: true);
    final carId = base.toUrlEncoding<int>(builtInConverters, this.carId);
    return base.createLocation('$carId', queryParams, previous);
  }

  CarsPageRoute get carsPageRoute => previous;
  HomePageRoute get homePageRoute => previous.previous;
  @override
  List<int> get numbers => previous.previous.numbers;
  @override
  int get age => previous.previous.age;
  @override
  String get myName => previous.previous.myName;
}

const builtInConverters = <base.Converter>[base.IntConverter(), base.StringConverter(), base.BoolConverter(), base.DoubleConverter()];

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

final routerData = base.FileRouterData(
  currentRouteIs: currentRouteIs,
  errorBuilder: base.getErrorBuilder(error),
  routes: [
    base.ShellRoute(
      builder: (BuildContext context, base.GoRouterState state, Widget child) {
        final storedRoute = base.InheritedRoute.of(context).route as HomePageRoute;
        return RootShell(route: storedRoute, child: child);
      },
      routes: [
        base.GoRoute(
          path: '/',
          builder: (BuildContext context, base.GoRouterState state) {
            return HomePage(base.getRoute<HomePageRoute>(context));
          },
          routes: [
            base.GoRoute(
              path: 'about',
              builder: (BuildContext context, base.GoRouterState state) {
                return AboutPage(base.getRoute<AboutPageRoute>(context));
              },
              redirect: base.getRedirect<AboutPageRoute>(aboutPageRouteRedirect.redirect, AboutPageRoute.fromGoRouterState),
            ),
            base.GoRoute(
              path: 'cars',
              builder: (BuildContext context, base.GoRouterState state) {
                return CarsPage(base.getRoute<CarsPageRoute>(context));
              },
              routes: [
                base.GoRoute(
                  path: ':carId',
                  builder: (BuildContext context, base.GoRouterState state) {
                    return CarPage(base.getRoute<CarPageRoute>(context));
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
