import 'extractor.dart';

void main(List<String> args) {
  final routes = extractRoutes();
  for (final route in routes) {
    print(route.toCustomString(""));
  }
}
