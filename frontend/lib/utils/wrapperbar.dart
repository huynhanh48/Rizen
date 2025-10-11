import 'package:flutter/material.dart';
import 'package:mobileapp/pages/about.dart';
import 'package:mobileapp/services/authservice.dart';
import 'package:mobileapp/utils/navbar.dart';

class WrapperBar extends StatefulWidget {
  const WrapperBar({super.key, required this.child});
  final Widget child;
  @override
  State<WrapperBar> createState() => _WrapperBarState();
}

class _WrapperBarState extends State<WrapperBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustome(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
          child: Column(children: [widget.child]),
        ),
      ),
      bottomNavigationBar: Navbar(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        child: Icon(Icons.support_agent_outlined, size: 40),
        onPressed: () {},
        backgroundColor: Colors.green.shade400,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
    );
  }
}

class AppBarCustome extends StatelessWidget implements PreferredSizeWidget {
  AppBarCustome({super.key});
  final Authservice authservice = new Authservice();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hint: Text("Search"),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide(width: 1, color: Colors.grey.shade500),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
      leadingWidth: 270,
      actions: [
        iconProfile(
          iconCustome: Icon(Icons.person),
          iconCallBack: () {
            Navigator.pushNamed(context, "/home/setting");
          },
        ),
        iconProfile(
          iconCustome: Icon(Icons.notifications),
          iconCallBack: () {
            print("----icon notification -----");
          },
        ),
      ],
    );
  }

  // bắt buộc override khi implements PreferredSizeWidget
  @override
  Size get preferredSize => const Size.fromHeight(40);
}

typedef CallBack = void Function();

class iconProfile extends StatelessWidget {
  iconProfile({super.key, this.iconCustome, required this.iconCallBack});
  final iconCustome;
  final CallBack iconCallBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 15),
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(width: 1, color: Colors.grey.shade400),
      ),

      width: 40,
      child: IconButton(onPressed: iconCallBack, icon: iconCustome),
    );
  }
}
