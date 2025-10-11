import 'package:flutter/material.dart';
import 'package:mobileapp/utils/wrapperbar.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 15, left: 20, right: 20),
      height: 82,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconNav(
            icon: Icons.home,
            label: "Trang chu",
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              print("current : ${currentRoute}");
              // Nếu chưa ở /home thì mới chuyển
              if (currentRoute != '/home') {
                Navigator.pushNamed(context, '/home');
              }
            },
          ),
          IconNav(
            icon: Icons.store_mall_directory_outlined,
            label: "Thi truong",
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              if (currentRoute != '/home/market') {
                Navigator.pushNamed(context, "/home/market");
              }
            },
          ),
          IconNav(
            icon: Icons.incomplete_circle_rounded,
            label: "Theo doi",
            onTap: () {},
          ),
          IconNav(icon: Icons.more, label: "Them", onTap: () {}),
        ],
      ),
    );
  }
}

typedef CallBack = void Function();

class IconNav extends StatelessWidget {
  const IconNav({super.key, required this.onTap, this.icon, this.label});
  final CallBack onTap;
  final icon;
  final label;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(6),
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          width: 80,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Icon(icon), Text("${label}")],
            ),
          ),
        ),
      ),
    );
  }
}
