import 'package:flutter/material.dart';
import "package:go_router/go_router.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: "/",
        builder: (context, state) {
          return const Page("First Page", "/first");
        },
        routes: [
          GoRoute(
            path: "first",
            builder: (context, state) => const Page("HomePage", "/"),
          ),
        ],
      ),
      GoRoute(
          path: "/one",
          builder: (context, state) {
            return const Page("HOmePage", "/");
          })
    ],
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class Page extends StatelessWidget {
  const Page(this.name, this.path);

  final String name;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text(name),
          onPressed: () => context.push(path, extra: "The TItle"),
        ),
      ),
    );
  }
}
