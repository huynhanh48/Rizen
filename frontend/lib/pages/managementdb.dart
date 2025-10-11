import 'package:flutter/material.dart';
import 'package:mobileapp/utils/wrapperbar.dart';

class Managementdb extends StatefulWidget {
  const Managementdb({super.key});

  @override
  State<Managementdb> createState() => _ManagementdbState();
}

class _ManagementdbState extends State<Managementdb> {
  @override
  Widget build(BuildContext context) {
    return WrapperBar(child: Text("data"));
  }
}
