import 'package:fuckit/file_router.dart';
import 'package:flutter/material.dart';

class CarPage extends StatelessPage<CarPageRoute> {
  const CarPage(super.route, {super.key});

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
