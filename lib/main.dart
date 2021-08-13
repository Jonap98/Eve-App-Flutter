import 'package:flutter/material.dart';

import 'package:mm_app/pages/initial_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eve App',
      home: InitialPage(),
    );
  }
}
