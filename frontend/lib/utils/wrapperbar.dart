import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mobileapp/api/collection.dart';
import 'package:mobileapp/pages/about.dart';
import 'package:mobileapp/services/authservice.dart';
import 'package:mobileapp/utils/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WrapperBar extends StatefulWidget {
  WrapperBar({super.key, required this.child});
  final Widget child;
  Authservice client = Authservice();
  @override
  State<WrapperBar> createState() => _WrapperBarState();
}

List<Map<String, dynamic>> listslidebar = [
  {"Icon": Icons.search, "Title": "Tìm cuộc trò chuyện "},
  {"Icon": Icons.add, "Title": "thêm cuộc trò chuyện mới"},
  {"Icon": Icons.save_alt_outlined, "Title": "Dự án lưu trữ"},
  {"Icon": Icons.storage, "Title": "Import dự liệu"},
];

class _WrapperBarState extends State<WrapperBar> {
  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();
  bool showModal = false;
  List<dynamic> data = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      endDrawer: slideBar(data: data.length == 0 ? [] : data),
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
        onPressed: () async {
          _globalKey.currentState?.openEndDrawer();
          final user = widget.client.getUser();
          print(user);
          final result = await collectionChat(username: user!["username"]);
          setState(() {
            data = result?["collection"] ?? [];
          });
          print(result?["collection"]);
        },
        backgroundColor: Colors.green.shade400,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
    );
  }
}

class slideBar extends StatelessWidget {
  slideBar({super.key, required this.data});
  final List<dynamic> data;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, _index) {
                return SizedBox(
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        print(_index);
                      },
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(listslidebar[_index]["Icon"], size: 20),
                          SizedBox(width: 10),
                          Text(
                            "${listslidebar[_index]["Title"]}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, _index) {
                return SizedBox.shrink();
              },
              itemCount: listslidebar.length,
            ),
          ),
          Divider(endIndent: 20, indent: 20),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                Text(
                  "Các cuộc trò truyện gần đây",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, _index) {
                      return InkWell(
                        onTap: () {
                          print(data[_index]["slug"]);
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: {
                              "slug": data[_index]["slug"],
                              "name": "${data[_index]["name"]}",
                            },
                          );
                        },
                        child: SizedBox(
                          height: 40,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${data[_index]["name"]}"),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: data.length,
                  ),
                ),
              ],
            ),
          ),
        ],
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
