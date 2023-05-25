import 'package:ex1/file_router.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessPage<AboutPageRoute> {
  const AboutPage(super.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              context.goRoute(const HomePageRoute(age: 6));
            },
            child: const Text("Back"),
          ),
          Text("name: ${route.name}"),
          Text("id: ${route.id}"),
          Text("isAdmin: ${route.isAdmin}"),
          Text("percentage: ${route.percentage}"),
        ],
      ),
    );
  }
}
