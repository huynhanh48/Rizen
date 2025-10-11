import 'package:flutter/material.dart';
import 'package:mobileapp/services/authservice.dart';
import 'package:mobileapp/utils/wrapper.dart';
import 'package:mobileapp/utils/wrapperbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeSetting extends StatelessWidget {
  HomeSetting({super.key});
  final List<Color> gradientColors = [
    Colors.green.shade400,
    Colors.green.shade700,
  ];
  final List<Map<String, dynamic>> ListItems = [
    {"title": "Tài Khoản", "icon": Icon(Icons.person), "navigatorLink": ""},
    {
      "title": "Biểu Đồ",
      "icon": Icon(Icons.analytics_outlined),
      "navigatorLink": "",
    },
    {
      "title": "Đơn Hàng",
      "icon": Icon(Icons.shopping_cart_checkout_sharp),
      "navigatorLink": "",
    },
    {
      "title": "ChatBox",
      "icon": Icon(Icons.chat_outlined),
      "navigatorLink": "",
    },
    {
      "title": "Database",
      "icon": Icon(Icons.table_rows),
      "navigatorLink": "/home/setting/database",
    },
  ];
  @override
  Widget build(BuildContext context) {
    final auther = Supabase.instance.client.auth.currentUser;
    return Wrapper(
      appBar: AppBarSetting(gradientColors: gradientColors, auther: auther),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemCount: ListItems.length,
          itemBuilder: (context, index) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (ListItems[index]["navigatorLink"].toString().isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      ListItems[index]["navigatorLink"],
                    );
                  }
                },
                child: Card(
                  // elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ListItems[index]["icon"],
                            SizedBox(width: 20),
                            Text("${ListItems[index]["title"]}"),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          fontWeight: FontWeight.w100,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AppBarSetting extends StatelessWidget implements PreferredSizeWidget {
  AppBarSetting({
    super.key,
    required this.gradientColors,
    required this.auther,
  });

  final List<Color> gradientColors;
  final User? auther;
  Authservice authservice = Authservice();
  @override
  Size get preferredSize => Size.fromHeight(80);
  @override
  Widget build(BuildContext context) {
    return SettingAppBar(
      gradientColors: gradientColors,
      auther: auther,
      authservice: authservice,
    );
  }
}

class SettingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingAppBar({
    super.key,
    required this.gradientColors,
    required this.auther,
    required this.authservice,
  });

  final List<Color> gradientColors;
  final User? auther;
  final Authservice authservice;

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 90,
      iconTheme: IconThemeData(color: Colors.white),
      leading: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          bottom: 30,
        ), // di chuyển vào trong
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios), // đổi icon
          onPressed: () => Navigator.pop(context), // hành động quay lại
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors, stops: [0.4, 1]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 50, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person),
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              "${auther?.userMetadata?["username"] ?? "Unknown"}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Menber",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.shopify_sharp, color: Colors.white),
                      ),
                    ],
                  ),
                  auther?.userMetadata?["username"] != null
                      ? IconButton(
                          onPressed: () async {
                            await authservice.signOut();
                            Navigator.pushNamed(context, "/");
                          },
                          icon: Icon(Icons.logout_sharp, color: Colors.white),
                        )
                      : IconButton(
                          onPressed: () {
                            print("object");
                          },
                          icon: Icon(Icons.login, color: Colors.white),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
