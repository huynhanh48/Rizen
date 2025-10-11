import 'package:flutter/material.dart';
import 'package:mobileapp/api/resetpassword.dart';
import 'package:mobileapp/model/imghome.dart';

class ResetEmail extends StatefulWidget {
  const ResetEmail({super.key});

  @override
  State<ResetEmail> createState() => _ResetEmailState();
}

class _ResetEmailState extends State<ResetEmail> {
  final TextEditingController _email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Wrap(
      child: Column(
        children: [
          ImageHome(path: "assets/login.svg", semanticslabel: "imageLogin").svg,
          ListTile(
            title: Center(child: Text("Khôi phục mật khẩu")),
            subtitle: Center(
              child: Text(
                "Mã xác thực sẽ gửi về Email, hãy kiểm tra email để lấy mã xác thực",
                textAlign: TextAlign.center,
              ),
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
          SizedBox(height: 20),
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

          SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return Center(child: CircularProgressIndicator());
                },
              );
              final result = await resetPassword(email: _email.text);
              Navigator.of(context).pop();
              result['message'] == "successful"
                  ? Navigator.pushNamed(
                      context,
                      "/authentication/verify",
                      arguments: {
                        "email": _email.text,
                        "method": "resetpassword",
                      },
                    )
                  : ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${result["message"]}"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
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
                  "Khôi phục mật khẩu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
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
