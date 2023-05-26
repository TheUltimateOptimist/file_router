import 'package:ex1/file_router.dart';
import 'package:flutter/material.dart';

class CarPage extends StatelessPage<CarPageRoute> {
  const CarPage(super.route, {super.key});

  @override
  Widget build(BuildContext context) {
    if (route.carId == 1) {
      throw Exception("test exception");
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("car id: ${route.carId}"),
            ElevatedButton(
              child: const Text("Cars"),
              onPressed: () {
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
