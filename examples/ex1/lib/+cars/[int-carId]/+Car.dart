import 'package:flutter/material.dart';
import 'package:ex1/file_router.dart';

class Car extends StatelessPage<CarRoute> {
  const Car(super.route, {super.key});

  @override
  Widget build(BuildContext context) {
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
    ));
  }
}
