///THIS FILE IS GENERATED! DO NOT EDIT IT MANUALLY!///

// ignore_for_file: constant_identifier_names
// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:file_router/file_router.dart' as base;

import 'package:ex1/+Index.dart';
import 'package:ex1/+about/+About.dart';
import 'package:ex1/+cars/+Cars.dart';
import 'package:ex1/+cars/[int-carId]/+Car.dart';

export 'package:file_router/file_router.dart';

class IndexRoute implements base.Route {
  const IndexRoute();

  

  @override
  String get location {
    String queryPath = '';
    
    return '/$queryPath';
  }

  @override
  Object? get extra => null;
}
class AboutRoute implements base.Route {
  const AboutRoute({required this.id, required this.name, required this.isAdmin, required this.percentage, });

  final int id;
final String name;
final bool isAdmin;
final double percentage;


  @override
  String get location {
    String queryPath = '';
    final idValue = int_converter.toUrlEncoding(id);
queryPath += queryPath.isEmpty ? '?id=$idValue' : '&id=$idValue';
final nameValue = String_converter.toUrlEncoding(name);
queryPath += queryPath.isEmpty ? '?name=$nameValue' : '&name=$nameValue';
final isAdminValue = bool_converter.toUrlEncoding(isAdmin);
queryPath += queryPath.isEmpty ? '?isAdmin=$isAdminValue' : '&isAdmin=$isAdminValue';
final percentageValue = double_converter.toUrlEncoding(percentage);
queryPath += queryPath.isEmpty ? '?percentage=$percentageValue' : '&percentage=$percentageValue';

    return '/about$queryPath';
  }

  @override
  Object? get extra => null;
}
class CarsRoute implements base.Route {
  const CarsRoute();

  

  @override
  String get location {
    String queryPath = '';
    
    return '/cars$queryPath';
  }

  @override
  Object? get extra => null;
}
class CarRoute implements base.Route {
  const CarRoute(this.carId, );

  final int carId;


  @override
  String get location {
    String queryPath = '';
    
final carIdValue = int_converter.toUrlEncoding(carId);
    return '/cars/$carIdValue$queryPath';
  }

  @override
  Object? get extra => null;
}


const int_converter = base.IntConverter();
const String_converter = base.StringConverter();
const bool_converter = base.BoolConverter();
const double_converter = base.DoubleConverter();

final routerData = base.FileRouterData(routes: [
  base.GoRoute(
  path: '/',
  builder: (BuildContext context, base.GoRouterState state) {
    
    const route = IndexRoute();
    return const Index(route);
  },
  routes: [
base.GoRoute(
  path: 'about',
  builder: (BuildContext context, base.GoRouterState state) {
    
final id = int_converter.fromUrlEncoding(state.queryParams['id']!);
final name = String_converter.fromUrlEncoding(state.queryParams['name']!);
final isAdmin = bool_converter.fromUrlEncoding(state.queryParams['isAdmin']!);
final percentage = double_converter.fromUrlEncoding(state.queryParams['percentage']!);
    final route = AboutRoute(id: id, name: name, isAdmin: isAdmin, percentage: percentage, );
    return About(route);
  },
  ),base.GoRoute(
  path: 'cars',
  builder: (BuildContext context, base.GoRouterState state) {
    
    const route = CarsRoute();
    return const Cars(route);
  },
  routes: [
base.GoRoute(
  path: ':carId',
  builder: (BuildContext context, base.GoRouterState state) {
    
final carId = int_converter.fromUrlEncoding(state.params['carId']!);
    final route = CarRoute(carId, );
    return Car(route);
  },
  ),],),],),],);
