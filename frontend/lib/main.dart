import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapp/authentication/changepassword.dart';
import 'package:mobileapp/authentication/resetemail.dart';
import 'package:mobileapp/authentication/resetpassword.dart';
import 'package:mobileapp/authentication/signin.dart';
import 'package:mobileapp/authentication/signup.dart';
import 'package:mobileapp/authentication/successful.dart';
import 'package:mobileapp/authentication/verify.dart';
import 'package:mobileapp/middleware/authgetway.dart';
import 'package:mobileapp/model/setting.dart';
import 'package:mobileapp/pages/home.dart';
import 'package:mobileapp/pages/homemarket.dart';
import 'package:mobileapp/pages/managementdb.dart';
import 'package:mobileapp/pages/showproduct.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: "https://bkepbkeihasukpwmuufz.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrZXBia2VpaGFzdWtwd211dWZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxMzA1NjgsImV4cCI6MjA3NDcwNjU2OH0.finhIeXmgvmntMDWwB4zj2gs-_nvPFTdbJ_t9dP9XlA",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "EcomnomicGrowth",
      theme: ThemeData(fontFamily: "Inter"),
      routes: {
        '/home': (context) => HomeState(), //HomeState
        '/authentication/login': (context) => LoginState(),
        '/authentication/register': (context) => RegisterState(),
        '/authentication/verify': (context) => Verify(),
        '/authentication/resetemail': (context) => ResetEmail(),
        '/authentication/resetpassword': (context) => Resetpassword(),
        '/authentication/successful': (context) => Successful(),
        '/authentication/changepassword': (context) => ChangePassword(),
        '/home/setting': (context) => HomeSetting(),
        '/home/setting/database': (context) => Managementdb(),
        '/home/market': (context) => HomeMarket(),
        '/home/showproduct': (context) => ShowProduct(),
      },
      home: AuthGetWay(),
    );
  }
}
