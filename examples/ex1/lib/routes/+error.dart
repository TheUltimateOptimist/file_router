import 'package:ex1/file_router.dart';
import "package:flutter/material.dart" hide Route;

Widget error(BuildContext context, Route route) {
  print("it worked");
  return const Scaffold(
    body: Center(
      child: Text("An error occurred"),
    ),
  );
}
