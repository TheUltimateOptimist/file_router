import 'package:fuckit/file_router.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessPage<HomePageRoute> {
  const HomePage(super.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("About"),
              onPressed: () {
                context.goRoute(
                  AboutPageRoute(
                    route,
                    name: "Jonathan",
                    id: 45,
                    isAdmin: true,
                    percentage: 4.5,
                  ),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Cars"),
              onPressed: () {
                context.goRoute(
                  CarsPageRoute(route),
                );
              },
            ),
            Text(route.numbers.toString()),
          ],
        ),
      ),
    );
  }
}
