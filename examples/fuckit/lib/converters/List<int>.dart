List<int> fromUrlEncoding(String data) {
  return data.split("a").map((part) => int.parse(part)).toList();
}

String toUrlEncoding(List<int> data) {
  return data.join("a");
}
