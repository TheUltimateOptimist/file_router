import 'package:testit/file_router.dart';

class RootShell extends StatelessShell {
  const RootShell(super.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// class RootShell extends StatefulShell {
//   const RootShell(super.child, {super.key});

//   @override
//   State<RootShell> createState() => _RootShellState(); 
// }

// class _RootShellState extends State<RootShell> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder(); 
//   }
// }
