import 'package:flutter/material.dart';
import 'package:ex1/file_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final fileRouter = FileRouter(
    routerData,
    initialRoute: const IndexRoute(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: fileRouter,
    );
  }
}
