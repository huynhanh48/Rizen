import 'package:flutter/material.dart';
import 'package:mobileapp/model/imghome.dart';

class Successful extends StatefulWidget {
  const Successful({super.key});

  @override
  State<Successful> createState() => _SuccessfulState();
}

class _SuccessfulState extends State<Successful> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      child: Column(
        children: [
          ImageHome(
            path: "assets/successful.svg",
            semanticslabel: "imagesuccessful",
          ).svg,
          SizedBox(height: 40),
          Text(
            "Mật khẩu đã được cập nhật",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text("Mật khẩu của bạn đã được cập nhật thành công"),
          SizedBox(height: 40),
          GestureDetector(
            onTap: () => {
              Navigator.pushNamed(context, "/authentication/login"),
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
                  "Trở lại đăng nhập",
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
