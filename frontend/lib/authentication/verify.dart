import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobileapp/api/resetcode.dart';
import 'package:mobileapp/api/verifycode.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  List<TextEditingController> eachCode = List.generate(
    4,
    (index) => TextEditingController(),
  );
  late List<FocusNode> focusNodes;

  static const int maxSeconds = 180; // 3 phút
  int secondsRemaining = maxSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(eachCode.length, (_) => FocusNode());
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    secondsRemaining = maxSeconds;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in eachCode) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    timer?.cancel();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < eachCode.length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
  }

  String get timerText {
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final email = args?['email'] ?? '';
    final bool isResetPassword = args?['method'] == "resetpassword"
        ? true
        : false;
    return Wrap(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Nhập mã xác thực",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "Sử dụng mã 4 chữ số mà chúng tôi vừa nhắn tin đến số Email của bạn, ${email}",
          ),
          SizedBox(height: 31),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(eachCode.length, (index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                  color: Color.fromRGBO(242, 242, 242, 1),
                ),
                width: 40,
                height: 60,
                child: Center(
                  child: TextField(
                    focusNode: focusNodes[index],
                    onChanged: (value) => _onChanged(value, index),
                    controller: eachCode[index],
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(4),
                      counterText: "",
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 40),
          GestureDetector(
            onTap: () async {
              String code = eachCode.map((e) => e.text).join("");
              showDialog(
                context: context,
                builder: (context) {
                  return Center(child: CircularProgressIndicator());
                },
              );
              final result = await verifycode(email: email, code: code);

              Navigator.of(context).pop();
              print("${code}, ${email}---");
              if (isResetPassword) {
                Navigator.pushNamed(
                  context,
                  "/authentication/changepassword",
                  arguments: {"email": email},
                );
              } else {
                if (result?['message'] == "successful") {
                  Navigator.pushNamed(context, "/authentication/successful");
                } else {
                  print(result);
                }
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
                  "Xác Nhận ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          GestureDetector(
            onTap: secondsRemaining == 0
                ? () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Center(child: CircularProgressIndicator());
                      },
                    );
                    await resetcode(email: email);
                    Navigator.of(context).pop();
                    startTimer(); // Khởi động lại đếm ngược khi gửi lại mã
                  }
                : null,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: secondsRemaining == 0
                    ? Color.fromRGBO(242, 242, 242, 1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 1,
                  color: Color.fromRGBO(151, 0, 193, 1),
                ),
              ),
              child: Center(
                child: Text(
                  secondsRemaining == 0 ? "Gửi lại mã" : "Gửi lại $timerText",
                  style: TextStyle(
                    color: Color.fromRGBO(151, 0, 193, 1),
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
