import 'package:flutter/material.dart';
import 'package:mobileapp/pages/about.dart';
import 'package:mobileapp/pages/home.dart';
import 'package:mobileapp/pages/homemarket.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGetWay extends StatefulWidget {
  const AuthGetWay({super.key});

  @override
  State<AuthGetWay> createState() => _AuthGetWayState();
}

class _AuthGetWayState extends State<AuthGetWay> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final sessionUser = snapshot.hasData ? snapshot.data!.session : null;
        if (sessionUser?.user != null) {
          print(
            "current User : ${Supabase.instance.client.auth.currentUser?.email} --- ",
          );
          // da co user  /HomeState
          return HomeState();
        } else {
          // khong co user
          return AboutState();
        }
      },
    );
  }
}
