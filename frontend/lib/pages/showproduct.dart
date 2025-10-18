import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/api/prediction.dart';
import 'package:mobileapp/api/productgetname.dart';
import 'package:mobileapp/model/product.dart';
import 'package:mobileapp/utils/chartview.dart';
import 'package:mobileapp/utils/wrapperbar.dart';

class ShowProduct extends StatefulWidget {
  const ShowProduct({super.key});

  @override
  State<ShowProduct> createState() => _ShowProductState();
}

class _ShowProductState extends State<ShowProduct> {
  int selectMonth = 3;
  Product? _product;
  bool _loading = true;
  List<dynamic>? predictions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchProduct();
    });
  }

  Future<void> _fetchProduct() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final slug = args?["slug"];
    if (slug != null) {
      final result = await productGetName(slug);
      if (result != null && result.isNotEmpty) {
        final data = (result["data"] as List<dynamic>? ?? []).map((e) {
          return Map<String, dynamic>.from(e as Map);
        }).toList();

        if (data.isNotEmpty) {
          final predictionResult = await prediction(data);
          setState(() {
            _product = Product(
              name: result["name"] ?? "",
              year: result["year"] ?? 0,
              slug: slug,
              data: data,
            );
            predictions = predictionResult?['success'] == true
                ? predictionResult!['predictions']
                : [];
            _loading = false;
          });
        } else {
          setState(() {
            _loading = false;
          });
        }
      } else {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WrapperBar(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _product == null ? "" : _product!.name + "\n",
                    style: TextStyle(color: Colors.black),
                  ),

                  TextSpan(
                    text: _product != null
                        ? "${NumberFormat("#,###").format(_product!.getProductTotalWithIndex())} USD"
                        : "-",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 300,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _product == null
                ? const Center(child: Text("Không có dữ liệu"))
                : LineChartSample2(product: _product!, name: _product!.name),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildMonthButton("3 Tháng"),
                  const SizedBox(width: 10),
                  _buildMonthButton("6 Tháng"),
                  const SizedBox(width: 10),
                  _buildMonthButton("1 Năm"),
                  const SizedBox(width: 10),
                  _buildMonthButton("2 Năm"),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.zoom_in_sharp),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dự đoán kinh tế"),
              PopupMenuButton<int>(
                onSelected: (value) {
                  setState(() {
                    selectMonth = value;
                  });
                },
                position: PopupMenuPosition.under,
                child: Container(
                  width: 112,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Tháng $selectMonth"),
                      const Icon(Icons.arrow_drop_down_sharp),
                    ],
                  ),
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem(child: Text("Tháng 1"), value: 1),
                  PopupMenuItem(child: Text("Tháng 2"), value: 2),
                  PopupMenuItem(child: Text("Tháng 3"), value: 3),
                ],
              ),
            ],
          ),
          SingleChildScrollView(
            child: DataTable(
              dividerThickness: 0,

              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.transparent),
              ),
              columns: [
                DataColumn(label: Text("Year")),
                DataColumn(label: Text("Month")),
                DataColumn(label: Text("USD")),
                DataColumn(label: Text("Ton")),
              ],
              rows:
                  predictions
                      ?.map((e) {
                        return DataRow(
                          cells: [
                            DataCell(Text(e['year'].toString())),
                            DataCell(Text(e['month'].toString())),
                            DataCell(
                              Text(
                                NumberFormat(
                                  "#,###",
                                ).format((e['usd'] ?? 0).toDouble()),
                              ),
                            ),
                            DataCell(Text(e['ton'].toString())),
                          ],
                        );
                      })
                      .skip(3 - selectMonth)
                      .toList() ??
                  [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthButton(String text) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text),
    );
  }
}
