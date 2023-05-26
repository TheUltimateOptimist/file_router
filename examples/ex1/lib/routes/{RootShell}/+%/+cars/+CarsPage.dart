import 'package:ex1/file_router.dart';
import 'package:flutter/material.dart';

class CarsPage extends StatelessPage<CarsPageRoute> {
  const CarsPage(super.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("car one"),
              onPressed: () {
                context.goRoute(CarPageRoute(route, 1));
              },
            ),
            ElevatedButton(
              child: const Text("car two"),
              onPressed: () {
                context.goRoute(CarPageRoute(route, 2));
              },
            ),
            ElevatedButton(
              child: const Text("HOmepage"),
              onPressed: () {
                context.goRoute(const HomePageRoute(age: 3));
              },
            ),
          ],
        ),
      ),
    );
  }
}
