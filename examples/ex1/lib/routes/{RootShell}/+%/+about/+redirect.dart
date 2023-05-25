import 'dart:async';
import 'package:ex1/file_router.dart';

FutureOr<Route?> redirect(BuildContext context, AboutPageRoute route) {
  return CarsPageRoute(route.homePageRoute);
}
