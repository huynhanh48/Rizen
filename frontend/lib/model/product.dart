class Product {
  final String name;
  final int year;
  final String slug;
  final List<Map<String, dynamic>> data;

  Product({
    required this.name,
    required this.year,
    required this.slug,
    required this.data,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json["name"]?.toString() ?? "",
      year: int.tryParse(json["year"]?.toString() ?? "0") ?? 0,
      slug: json["slug"]?.toString() ?? "",
      data: (json["data"] as List<dynamic>? ?? []).map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        // đảm bảo month là String hoặc int
        if (map["month"] is! String && map["month"] is! int) {
          map["month"] = map["month"].toString();
        }
        return map;
      }).toList(),
    );
  }

  /// 👉 Tính tổng USD (lấy phần tử cuối hoặc tổng toàn bộ nếu cần)
  double getProductTotalWithIndex() {
    if (data.isEmpty) return 0;

    // Duyệt qua toàn bộ và cộng dồn giá trị usd
    final totalUsd = data.fold<double>(0, (sum, item) {
      final usd = item["usd"];
      if (usd is num) return sum + usd.toDouble();
      if (usd is String) return sum + (double.tryParse(usd) ?? 0);
      return sum;
    });

    return totalUsd;
  }
}
