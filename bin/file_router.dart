import 'extractor.dart';
import 'generator.dart';

void main(List<String> args) {
  final routes = extractRoutes();
  // for (final route in routes) {
  //   print(route.toCustomString(""));
  // }
  generateSource(routes);
}
