import 'package:flutter/material.dart';
import 'package:mobileapp/utils/navbar.dart';

class Wrapper extends StatelessWidget {
  Wrapper({super.key, required this.child, required this.appBar});
  final Widget child;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: child,
        ),
      ),
    );
  }
}
