import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/api/products.dart';
import 'package:mobileapp/model/product.dart';
import 'package:mobileapp/services/authservice.dart';
import 'package:mobileapp/utils/wrapperbar.dart';

class HomeMarket extends StatefulWidget {
  const HomeMarket({super.key});

  @override
  State<HomeMarket> createState() => _HomeMarketState();
}

class _HomeMarketState extends State<HomeMarket> {
  List<Product>? _list;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    final result = await getProducts();
    final List<dynamic> rawData = result?["data"] ?? [];

    setState(() {
      _list = rawData.map((item) => Product.fromJson(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WrapperBar(
      child: Expanded(
        child: ListView.separated(
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => Divider(),
          itemCount: _list?.length ?? 0,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/home/showproduct",
                  arguments: {"slug": _list?[index].slug},
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: EdgeInsets.all(0),
                height: 60,
                decoration: BoxDecoration(color: Colors.transparent),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              "${_list?[index].name}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_sharp,
                              color: Colors.green.shade500,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "${_list?[index].year}",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${NumberFormat("#,###").format(_list?[index].getProductTotalWithIndex())}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
