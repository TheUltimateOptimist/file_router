import 'package:flutter/material.dart';
import 'package:ex1/file_router.dart';

class Index extends StatelessPage {
  const Index(super.route, {super.key});

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
                  const AboutRoute(
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
                  const CarsRoute(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
