import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:mobileapp/api/products.dart';
import 'package:mobileapp/model/product.dart';
import 'package:mobileapp/services/authservice.dart';
import 'package:mobileapp/utils/chartview.dart';
import 'package:mobileapp/utils/wrapperbar.dart';

class HomeState extends StatefulWidget {
  const HomeState({super.key});

  @override
  State<HomeState> createState() => _HomeStateState();
}

class _HomeStateState extends State<HomeState> {
  final Authservice authservice = Authservice();

  final List<Map<String, dynamic>> topNavigation = [
    {"title": "Biến động", "icon": Icons.fireplace_outlined},
    {"title": "Kinh tế", "icon": Icons.eco_outlined},
    {"title": "Hàng hoá", "icon": Icons.category_rounded},
    {"title": "Phân tích", "icon": Icons.analytics_outlined},
  ];

  List<Product> data = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    final result = await getProducts();
    final List<dynamic> rawData = result?["data"] ?? [];
    setState(() {
      data = rawData.map((item) => Product.fromJson(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WrapperBar(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListNavigator(topNavigation: topNavigation),
            const SizedBox(height: 15),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Biến động hàng đầu",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // --- Danh sách sản phẩm ngang ---
            ViewProducts(data: data),

            const SizedBox(height: 15),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                data.isNotEmpty
                    ? "Chỉ số kinh tế mặt hàng đầu ${data[0].year}"
                    : "Chưa có dữ liệu",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                "Trị giá và lượng mặt hàng xuất khẩu sơ bộ ",
              ),
            ),

            ItemChart(data: data),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Ý kiến & Phân tích",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              height: 154,
              margin: const EdgeInsets.only(top: 5),
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    ChatList(),
                    SizedBox(height: 10),
                    ChatList(),
                    SizedBox(height: 10),
                    ChatList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewProducts extends StatelessWidget {
  const ViewProducts({super.key, required this.data});

  final List<Product> data;

  @override
  Widget build(BuildContext context) {
    // Nếu không có data
    if (data.isEmpty) {
      return const Center(child: Text("Đang tải..."));
    }

    // Giới hạn tối đa 10 phần tử hiển thị
    final itemCount = data.length > 10 ? 10 : data.length;

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final product = data[index];
          return SizedBox(
            width: 180,
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  title: SizedBox(
                    height:
                        20, // Giới hạn chiều cao để Marquee không lỗi layout
                    child: Marquee(
                      text: product.name ?? "Không có tên",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      blankSpace: 30.0,
                      velocity: 40.0, // tốc độ chạy
                      pauseAfterRound: const Duration(seconds: 1),
                      startPadding: 10.0,
                      accelerationDuration: const Duration(milliseconds: 800),
                      decelerationDuration: const Duration(milliseconds: 800),
                      accelerationCurve: Curves.linear,
                      decelerationCurve: Curves.easeOut,
                    ),
                  ),
                  subtitle: Text(
                    "${NumberFormat("#,###").format(product.getProductTotalWithIndex())} USD",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade400,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.person_pin, color: Colors.white),
        ),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: const ListTile(
              title: Text(
                "Sức mạnh mặt hàng nông nghiệp tháng 10/2025: Bền vững?",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text("Dalak AI | thg 9, 2025"),
            ),
          ),
        ),
      ],
    );
  }
}

class ItemChart extends StatelessWidget {
  const ItemChart({super.key, required this.data});

  final List<Product> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: data.isEmpty
          ? const Center(child: Text("Không có dữ liệu"))
          : LineChartSample2(product: data[0], name: data[0].name),
    );
  }
}

class ListNavigator extends StatelessWidget {
  const ListNavigator({super.key, required this.topNavigation});

  final List<Map<String, dynamic>> topNavigation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topNavigation.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Icon(topNavigation[index]["icon"]),
                const SizedBox(width: 5),
                Text("${topNavigation[index]["title"]}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
