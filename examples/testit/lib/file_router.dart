///THIS FILE IS GENERATED! DO NOT EDIT IT MANUALLY!///

// ignore_for_file: constant_identifier_names
// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:file_router/file_router.dart' as base;

import 'package:testit/routes/{RootShell}/{RootShell}.dart';
import 'package:testit/routes/{RootShell}/+|/+HomePage.dart';
import 'package:testit/routes/{RootShell}/+|/:int;userId|account/+Account.dart';
import 'package:testit/routes/{RootShell}/+|/:int;userId|account/=String||.dart'
    as AccountRoute_string;
import 'package:testit/routes/{RootShell}/+|/:int;userId|account/3-double;fraction||.dart'
    as AccountRoute_fraction;
import 'package:testit/routes/{RootShell}/+|/:int;userId|account/+number/+NumberPage.dart';

export 'package:file_router/file_router.dart';
export 'package:flutter/material.dart' show BuildContext, Widget, Placeholder, State;

class HomePageRoute implements base.Route {
  const HomePageRoute() : previous = null;

  static HomePageRoute _fromGoRouterState(base.GoRouterState state) {
    return HomePageRoute();
  }

  @override
  final base.Route? previous;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);

    return base.createLocation('/', queryParams, previous);
  }
}

class AccountRoute implements base.Route {
  const AccountRoute(
    this.previous,
    this.userId, {
    this.father,
    this.count,
    this.name = 'franz',
    this.age = 4,
    this.string = AccountRoute_string.defaultValue,
    this.fraction = AccountRoute_fraction.defaultValue,
  });

  static AccountRoute _fromGoRouterState(base.GoRouterState state) {
    final userId = int_converter.fromUrlEncoding(state.params['userId']!);
    final String? father;
    if (state.queryParams['father'] != null) {
      father = String_converter.fromUrlEncoding(state.queryParams['father']!);
    } else {
      father = null;
    }
    final age = int_converter.fromUrlEncoding(state.queryParams['age'] ?? '4');
    final double fraction;
    if (state.queryParams['fraction'] != null) {
      fraction = double_converter.fromUrlEncoding(state.queryParams['fraction']!);
    } else {
      fraction = AccountRoute_fraction.defaultValue;
    }

    return AccountRoute(
      HomePageRoute._fromGoRouterState(state),
      userId,
      father: father,
      age: age,
      fraction: fraction,
    );
  }

  @override
  final HomePageRoute previous;

  final int userId;
  final String? father;
  final int? count;
  final String name;
  final int age;
  final String string;
  final double fraction;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);

    final userId = int_converter.toUrlEncoding(this.userId);
    if (father != null) {
      queryParams.add((name: 'father', value: String_converter.toUrlEncoding(father!)));
    }
    queryParams.add((name: 'age', value: int_converter.toUrlEncoding(age)));
    queryParams.add((name: 'fraction', value: double_converter.toUrlEncoding(fraction)));

    return base.createLocation('$userId/account', queryParams, previous);
  }
}

class NumberPageRoute implements base.Route {
  const NumberPageRoute(
    this.previous, {
    this.isLarge = true,
  });

  static NumberPageRoute _fromGoRouterState(base.GoRouterState state) {
    final isLarge = bool_converter.fromUrlEncoding(state.queryParams['isLarge'] ?? 'true');
    return NumberPageRoute(
      AccountRoute._fromGoRouterState(state),
      isLarge: isLarge,
    );
  }

  @override
  final AccountRoute previous;

  final bool isLarge;

  @override
  String get location {
    final List<({String name, String value})> queryParams = List.empty(growable: true);
    queryParams.add((name: 'isLarge', value: bool_converter.toUrlEncoding(isLarge)));

    return base.createLocation('number', queryParams, previous);
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
  if (T == AccountRoute) {
    return base.isAPair('/:userId/account/', location);
  }
  if (T == NumberPageRoute) {
    return base.isAPair('/:userId/account/number/', location);
  }

  throw Exception("Route detection failure");
}

final routerData = base.FileRouterData(
  currentRouteIs: currentIs,
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
              path: ':userId/account',
              builder: (BuildContext context, base.GoRouterState state) {
                if (state.extra != null) {
                  return Account(base.getRoute<AccountRoute>(state.extra as base.Route));
                }
                return Account(AccountRoute._fromGoRouterState(state));
              },
              routes: [
                base.GoRoute(
                  path: 'number',
                  builder: (BuildContext context, base.GoRouterState state) {
                    if (state.extra != null) {
                      return NumberPage(base.getRoute<NumberPageRoute>(state.extra as base.Route));
                    }
                    return NumberPage(NumberPageRoute._fromGoRouterState(state));
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
