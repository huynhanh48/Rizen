import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/model/product.dart';
import 'dart:math';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({
    super.key,
    required this.product,
    required this.name,
  });

  final Product product;
  final String name;

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    Colors.greenAccent.shade200,
    Colors.green.shade600,
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 1.8, child: LineChart(mainData()));
  }

  /// Hiển thị nhãn trục X: chỉ tháng, xoay nhãn
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= widget.product.data.length)
      return const SizedBox();
    final item = widget.product.data[index];

    return SideTitleWidget(
      meta: meta,
      child: Transform.rotate(
        angle: 0, // xoay khoảng -30 độ
        child: Text("${item["month"]}", style: const TextStyle(fontSize: 10)),
      ),
    );
  }

  /// Hiển thị nhãn trục Y với scale động
  Widget rightTitleWidgets(double value, TitleMeta meta, double scale) {
    final displayValue = value * scale;
    String text;
    if (displayValue >= 1000) {
      text = '${(displayValue / 1000).toStringAsFixed(1)}K';
    } else {
      text = displayValue.toStringAsFixed(0);
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Dữ liệu biểu đồ chính
  LineChartData mainData() {
    final dataList = widget.product.data;

    // Tìm giá trị lớn nhất
    final maxUsdValue = dataList
        .map((e) => double.tryParse(e["usd"].toString()) ?? 0.0)
        .fold<double>(0, (prev, e) => max(prev, e));

    // Chọn scale tự động để chart không quá bé
    final scale = maxUsdValue > 10000
        ? maxUsdValue / 10000
        : maxUsdValue > 5000
        ? maxUsdValue / 5000
        : 1.0;

    // Tạo spots
    final spots = <FlSpot>[];
    for (var i = 0; i < dataList.length; i++) {
      final usd = double.tryParse(dataList[i]["usd"].toString()) ?? 0.0;
      spots.add(FlSpot(i.toDouble(), usd / scale));
    }

    final maxSpotY = spots.map((e) => e.y).reduce(max);

    return LineChartData(
      minX: 0,
      maxX: dataList.length - 1.toDouble(),
      minY: 0,
      maxY: maxSpotY * 1.1, // thêm 10% padding trên
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) =>
            const FlLine(color: Colors.grey, strokeWidth: 0.5),
        getDrawingVerticalLine: (value) =>
            const FlLine(color: Colors.grey, strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: (maxSpotY / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) =>
                rightTitleWidgets(value, meta, scale),
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.2))
                  .toList(),
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              final item = dataList[index];
              final usd = double.tryParse(item["usd"].toString()) ?? 0.0;
              return LineTooltipItem(
                "${item["month"]}/${item["year"]}\n",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'USD: ${NumberFormat("#,###").format(usd)}',
                    style: const TextStyle(color: Colors.amber, fontSize: 12),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
