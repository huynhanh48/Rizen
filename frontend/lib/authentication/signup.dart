import 'package:flutter/material.dart';
import 'package:mobileapp/api/register.dart';
import 'package:mobileapp/model/imghome.dart';
import 'package:mobileapp/services/authservice.dart';

class RegisterState extends StatefulWidget {
  const RegisterState({super.key});

  @override
  State<RegisterState> createState() => _RegisterStateState();
}

class _RegisterStateState extends State<RegisterState> {
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
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');
  @override
  Widget build(BuildContext context) {
    return Wrap(
      child: Column(
        children: [
          ListTile(
            isThreeLine: true,
            title: Text("Tạo tài khoản của bạn"),
            subtitle: Text(
              "Hãy cùng bắt đầu tạo 1 tài khoản về tài chính miễn phí",
            ),
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
            controller: _username,
            decoration: InputDecoration(
              filled: true,
              hint: Text("User Name"),
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
                  Text("Tôi chấp nhận những điều khoản"),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              if (!check) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                      child: Text("Vui lòng chấp nhận điều khoản để tiếp tục"),
                    ),
                  ),
                );
                return;
              }
              showDialog(
                context: context,
                builder: (context) {
                  return Center(child: CircularProgressIndicator());
                },
              );
              final successful = await register(
                username: _username.text,
                email: _email.text,
                password: _password.text,
              );
              await authservice.signUpWithEmailPassword(
                email: _email.text,
                password: _password.text,
                username: _username.text,
              );
              Navigator.of(context).pop();

              if (successful?['message'] == "successful") {
                Navigator.pushNamed(
                  context,
                  "/authentication/verify",
                  arguments: {"email": successful?["data"]["email"]},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${successful?["message"]}")),
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
                  "Đăng ký",
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
              Text("Đã có tài khoản?"),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/authentication/login");
                },
                child: Text(
                  "Đăng Nhập",
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
