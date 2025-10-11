import 'package:flutter/material.dart';
import 'package:mobileapp/api/changepassword.dart';
import 'package:mobileapp/utils/wrapper.dart';
import 'package:mobileapp/services/authservice.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final agr = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool show = true;
  bool check = false;
  Authservice authservice = Authservice();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmpassword = TextEditingController();

  final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');

  @override
  void initState() {
    super.initState();
    _password.addListener(() {
      setState(() {});
    });
    _confirmpassword.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _confirmpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agr =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Wrapper(
      appBar: null,
      child: Column(
        children: [
          ListTile(
            isThreeLine: true,
            title: const Center(child: Text("Thay đổi mật khẩu ")),
            subtitle: Center(child: Text("${agr?["email"] ?? ""}")),
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
            subtitleTextStyle: const TextStyle(
              color: Color.fromRGBO(130, 130, 130, 1),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),

          // password
          TextField(
            controller: _password,
            obscureText: show,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    show = !show;
                  });
                },
                icon: const Icon(Icons.remove_red_eye_sharp),
              ),
              errorText: _password.text.isEmpty
                  ? null
                  : passwordRegex.hasMatch(_password.text)
                  ? null
                  : 'Mật khẩu phải ≥6 ký tự, có chữ hoa, thường và số',
              filled: true,
              hintText: "Password",
              hintStyle: const TextStyle(
                color: Color.fromRGBO(130, 130, 130, 1),
              ),
              fillColor: const Color.fromRGBO(242, 242, 242, 1),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: Color.fromRGBO(151, 0, 193, 1),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // confirm password
          TextField(
            controller: _confirmpassword,
            obscureText: show,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    show = !show;
                  });
                },
                icon: const Icon(Icons.remove_red_eye_sharp),
              ),
              errorText: _confirmpassword.text.isEmpty
                  ? null
                  : passwordRegex.hasMatch(_password.text) &&
                        _password.text == _confirmpassword.text
                  ? null
                  : 'Mật khẩu không khớp !',
              filled: true,
              hintText: "Confirm Password",
              hintStyle: const TextStyle(
                color: Color.fromRGBO(130, 130, 130, 1),
              ),
              fillColor: const Color.fromRGBO(242, 242, 242, 1),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: Color.fromRGBO(151, 0, 193, 1),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              if (_password.text.compareTo(_confirmpassword.text) != 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(child: Text("Mật khẩu không khớp")),
                  ),
                );
                return;
              }

              showDialog(
                context: context,
                builder: (context) {
                  return const Center(child: CircularProgressIndicator());
                },
              );
              final result = await changepasswordApi(
                email: agr?["email"],
                password: _password.text,
              );
              if (result['message'] == "successful") {
                try {
                  final userService = await authservice.changePasswordWithEmail(
                    email: agr?["email"],
                    password: _password.text,
                  );
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.pushNamed(context, "/authentication/successful");
                  return;
                } on AuthApiException catch (e) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Lỗi: ${e.message}")));
                  return;
                } catch (e) {
                  // Lỗi khác
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Có lỗi xảy ra, thử lại sau")),
                  );
                  return;
                }
              }
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
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
                color: const Color.fromRGBO(151, 0, 193, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "Thay Đổi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          const Divider(height: 50, thickness: 2, indent: 70, endIndent: 70),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Đã có tài khoản?"),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/authentication/login");
                },
                child: const Text(
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
