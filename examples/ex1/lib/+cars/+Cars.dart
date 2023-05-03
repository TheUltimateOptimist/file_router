import 'package:flutter/material.dart';
import 'package:ex1/file_router.dart';

class Cars extends StatelessPage<CarsRoute> {
  const Cars(super.route, {super.key});

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
              context.goRoute(const CarRoute(1));
            },
          ),
          ElevatedButton(
            child: const Text("car two"),
            onPressed: () {
              context.goRoute(const CarRoute(2));
            },
          ),
          ElevatedButton(
            child: const Text("HOmepage"),
            onPressed: () {
              context.goRoute(const IndexRoute());
            },
          ),
        ],
      ),
    ));
  }
}
