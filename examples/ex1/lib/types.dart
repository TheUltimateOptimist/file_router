import "package:file_router/file_router.dart";

class IntListConverter implements Converter<List<int>> {
  const IntListConverter();

  @override
  List<int> fromUrlEncoding(String data) {
    return data.split("a").map((part) => int.parse(part)).toList();
  }

  @override
  String toUrlEncoding(List<int> data) {
    return data.join("a");
  }
}

const converters = [IntListConverter()];
