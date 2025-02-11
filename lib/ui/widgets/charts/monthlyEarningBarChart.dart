import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class MonthlyEarningBarChart extends StatefulWidget {
  const MonthlyEarningBarChart({super.key, required this.monthlySales});

  final List<MonthlySales> monthlySales;

  @override
  State<MonthlyEarningBarChart> createState() => _MonthlyEarningBarChartState();
}

class _MonthlyEarningBarChartState extends State<MonthlyEarningBarChart> {
  int maxAmount = 0;

  @override
  void initState() {
    if (widget.monthlySales.isNotEmpty) {
      final List<int> list = widget.monthlySales
          .map((MonthlySales e) =>
              int.parse(e.totalAmount.toString().split(".").first))
          .toList();
      maxAmount = list.reduce(max);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'monthlySales'.translate(context: context),
          style: TextStyle(
            color: Theme.of(context).colorScheme.blackColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const CustomSizedBox(
          height: 25,
        ),
        Expanded(
          child: BarChart(
            mainBarData(),
          ),
        ),
        const CustomSizedBox(
          height: 12,
        ),
      ],
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 22,
    List<int>? showTooltips,
    LinearGradient? barChartRodGradient,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          gradient: barChartRodGradient ??
              LinearGradient(
                colors: [Colors.green.shade300, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          toY: isTouched ? y + 1 : y,
          width: width,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(UiUtils.borderRadiusOf5),
              topRight: Radius.circular(UiUtils.borderRadiusOf5)),
          borderSide: isTouched
              ? BorderSide(color: Theme.of(context).colorScheme.blackColor)
              : BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .blackColor
                      .withValues(alpha: 0.7),
                  width: 0,
                ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() {
    return List.generate(widget.monthlySales.length, (int index) {
      int? colorIndex;
      colorIndex = index >= UiUtils.gradientColorForBarChart.length
          ? findColorIndex(index: index)
          : index;
      return makeGroupData(
        index,
        double.parse(widget.monthlySales[index].totalAmount!),
        width: (MediaQuery.sizeOf(context).width * 0.7) /
            (widget.monthlySales.length > 3 ? widget.monthlySales.length : 3),
        barChartRodGradient: UiUtils.gradientColorForBarChart[colorIndex!],
      );
    });
  }

  BarChartData mainBarData() {
    return BarChartData(
      maxY: maxAmount != 0 ? maxAmount + 500 : 0,
      alignment: BarChartAlignment.spaceEvenly,
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      barTouchData: BarTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent e, BarTouchResponse? f) {},
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (BarChartGroupData group, int groupIndex,
              BarChartRodData rod, int rodIndex) {
            final String selectedDate =
                widget.monthlySales[group.x].month ?? '';
            final String salesCount =
                widget.monthlySales[group.x].totalAmount ?? '';
            return BarTooltipItem(
              '',
              TextStyle(
                color: Theme.of(context).colorScheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: '$selectedDate\n',
                ),
                TextSpan(
                  text: salesCount.priceFormat(),
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                )
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getMonthTitle,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxAmount != 0 ? maxAmount / 4 : null,
            reservedSize: 40,
            getTitlesWidget: (double value, TitleMeta meta) {
              return CustomContainer(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  '${double.parse(
                    value.toString(),
                  )} ',
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.end,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.blackColor),
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: true,
      ),
    );
  }

  Widget getMonthTitle(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        '${widget.monthlySales[value.toInt()].month?.substring(0, 3)}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        softWrap: true,
      ),
    );
  }

  dynamic findColorIndex({required int index}) {
    final int difference = index - UiUtils.gradientColorForBarChart.length;
    if (difference < UiUtils.gradientColorForBarChart.length) {
      return difference;
    }
    return findColorIndex(index: difference);
  }
}
