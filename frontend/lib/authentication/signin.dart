import 'package:flutter/material.dart';
import 'package:mobileapp/api/verifypassword.dart';
import 'package:mobileapp/model/imghome.dart';
import 'package:mobileapp/services/authservice.dart';

class LoginState extends StatefulWidget {
  const LoginState({super.key});

  @override
  State<LoginState> createState() => _LoginStateState();
}

class _LoginStateState extends State<LoginState> {
  final authservice = Authservice();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _password.addListener(() {
      setState(() {});
    });
  }

  bool show = true;
  bool check = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');
  @override
  Widget build(BuildContext context) {
    return Wrap(
      child: Column(
        children: [
          ImageHome(path: "assets/login.svg", semanticslabel: "imageLogin").svg,
          ListTile(
            title: Center(child: Text("Get started")),
            subtitle: Center(child: Text("Nền tảng đầu tư All in One")),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
            subtitleTextStyle: TextStyle(
              color: Color.fromRGBO(130, 130, 130, 1),
              fontSize: 16,
            ),
          ),
          TextField(
            controller: _email,
            decoration: InputDecoration(
              filled: true,
              hint: Text("Email"),
              hintStyle: TextStyle(color: Color.fromRGBO(130, 130, 130, 1)),
              fillColor: Color.fromRGBO(242, 242, 242, 1),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: Color.fromRGBO(151, 0, 193, 1),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          TextField(
            controller: _password,
            obscureText: show,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  show = !show;
                  setState(() {});
                },
                icon: Icon(Icons.remove_red_eye_sharp),
              ),
              errorText: _password.text.isEmpty
                  ? null
                  : passwordRegex.hasMatch(_password.text)
                  ? null
                  : 'Mật khẩu phải ≥6 ký tự, có chữ hoa, thường và số',
              filled: true,
              hint: Text("Password"),
              hintStyle: TextStyle(color: Color.fromRGBO(130, 130, 130, 1)),
              fillColor: Color.fromRGBO(242, 242, 242, 1),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: Color.fromRGBO(151, 0, 193, 1),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    semanticLabel: "text",
                    side: BorderSide(color: Color.fromRGBO(111, 111, 111, 1)),
                    checkColor: Colors.white,
                    value: check,
                    onChanged: (bool? value) {
                      setState(() {
                        check = !check;
                      });
                    },
                  ),
                  Text("Lưu mật khẩu"),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/authentication/resetemail");
                },
                child: Text("Quên mật khẩu?"),
              ),
            ],
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final result = await verifyPassword(
                email: _email.text,
                password: _password.text,
              );
              if (result["message"] == "successful") {
                final response = await authservice.signInWithEmailPassword(
                  Password: _password.text,
                  Email: _email.text,
                  Username: result["data"]["username"],
                );
                Navigator.pushNamed(context, "/home");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Login failed!"),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Color.fromRGBO(151, 0, 193, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 50, thickness: 2, indent: 70, endIndent: 70),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Chưa có tài khoản?"),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/authentication/register");
                },
                child: Text(
                  "Đăng Ký",
                  style: TextStyle(color: Color.fromRGBO(151, 0, 193, 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Wrap extends StatelessWidget {
  const Wrap({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: child,
        ),
      ),
    );
  }
}
