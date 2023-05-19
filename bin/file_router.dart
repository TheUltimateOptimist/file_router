import 'extractor.dart';
import 'generator.dart';

void main(List<String> args) {
  final routes = extractRoutes();
  generateSource(routes);
}
