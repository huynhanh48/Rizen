import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _BarChart extends StatelessWidget {
  final List<dynamic>? data;
  final int monthCurrent;

  const _BarChart({this.data, required this.monthCurrent});

  @override
  Widget build(BuildContext context) {
    final double maxYValue = _calculateMaxY();

    return BarChart(
      BarChartData(
        barTouchData: _barTouchData,
        titlesData: _titlesData,
        borderData: _borderData,
        barGroups: _barGroups,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: maxYValue,
      ),
    );
  }

  double _calculateMaxY() {
    if (data != null && data!.isNotEmpty) {
      final maxUsd = data!
          .map((e) => (e["usd"] ?? 0).toDouble())
          .reduce((a, b) => a > b ? a : b);
      return maxUsd * 1.2; // thêm 20% cho không chạm trần
    }
    return 20;
  }

  BarTouchData get _barTouchData => BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (_) => Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final formatted = NumberFormat("#,###").format(rod.toY);
        return BarTooltipItem(
          formatted,
          const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        );
      },
    ),
  );

  Widget _getTitles(double value, TitleMeta meta) {
    final style = const TextStyle(
      color: Colors.blueGrey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    String text = '';
    if (data != null && data!.isNotEmpty) {
      int index = value.toInt();
      if (index >= 0 && index < monthCurrent) {
        text = "M${data![index]["month"]}";
      }
    } else {
      // fallback dữ liệu cứng
      text = switch (value.toInt()) {
        0 => 'Mn',
        1 => 'Te',
        2 => 'Wd',
        _ => '',
      };
    }

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get _titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: _getTitles,
      ),
    ),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  FlBorderData get _borderData => FlBorderData(show: false);

  LinearGradient get _barsGradient => const LinearGradient(
    colors: [Colors.blueGrey, Colors.green],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> get _barGroups {
    if (data != null && data!.isNotEmpty) {
      int count = monthCurrent.clamp(1, data!.length);
      return List.generate(count, (index) {
        final monthData = data![index];
        final usd = (monthData["usd"] ?? 0).toDouble();
        return BarChartGroupData(
          x: index,
          barRods: [BarChartRodData(toY: usd, gradient: _barsGradient)],
          showingTooltipIndicators: [0],
        );
      });
    } else {
      // fallback dữ liệu cứng
      return [
        BarChartGroupData(
          x: 0,
          barRods: [BarChartRodData(toY: 8, gradient: _barsGradient)],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [BarChartRodData(toY: 10, gradient: _barsGradient)],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [BarChartRodData(toY: 14, gradient: _barsGradient)],
          showingTooltipIndicators: [0],
        ),
      ];
    }
  }
}

class BarChartSample3 extends StatelessWidget {
  final List<dynamic>? data;
  final int monthCurrent;

  const BarChartSample3({super.key, this.data, this.monthCurrent = 3});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: _BarChart(data: data, monthCurrent: monthCurrent),
    );
  }
}
