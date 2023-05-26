import 'package:ex1/file_router.dart';

import 'package:flutter/material.dart';

class RootShell extends StatelessShell {
  const RootShell(super.child, {super.key});

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    if (context.currentRouteIs<AboutPageRoute>()) {
      currentIndex = 1;
    } else if (context.currentRouteIs<CarsPageRoute>() || context.currentRouteIs<CarPageRoute>()) {
      currentIndex = 2;
    }
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_outlined), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.car_crash), label: "Cars")
        ],
        currentIndex: currentIndex,
        onTap: (value) {
          switch (value) {
            case 0:
              return context.goRoute(const HomePageRoute(age: 4));
            case 1:
              return context.goRoute(const AboutPageRoute(
                HomePageRoute(),
                id: 23,
                name: "Jonathan",
                isAdmin: true,
                percentage: 34.5,
              ));
            case 2:
              return context.goRoute(
                const CarsPageRoute(
                  HomePageRoute(),
                ),
              );
          }
        },
      ),
    );
  }
}
