import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MoodChartWidget extends StatelessWidget {
  final List<MoodChartData> data;
  final String period; // 'week', 'month', 'year'

  const MoodChartWidget({
    super.key,
    required this.data,
    this.period = 'week',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No hay datos suficientes para mostrar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
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
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= data.length) {
                    return const Text('');
                  }
                  final date = data[value.toInt()].date;
                  String label;

                  switch (period) {
                    case 'week':
                      label = DateFormat('E', 'es').format(date);
                      break;
                    case 'month':
                      label = DateFormat('d', 'es').format(date);
                      break;
                    case 'year':
                      label = DateFormat('MMM', 'es').format(date);
                      break;
                    default:
                      label = DateFormat('d', 'es').format(date);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  const moods = ['', 'Muy mal', 'Mal', 'Neutral', 'Bien', 'Muy bien'];
                  if (value < 1 || value > 5) {
                    return const Text('');
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      moods[value.toInt()],
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              left: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 1,
          maxY: 5,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.moodValue.toDouble(),
                );
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: Theme.of(context).colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  const moods = ['', 'Muy mal', 'Mal', 'Neutral', 'Bien', 'Muy bien'];
                  final date = data[spot.x.toInt()].date;
                  final dateStr = DateFormat('d MMM', 'es').format(date);

                  return LineTooltipItem(
                    '$dateStr\n${moods[spot.y.toInt()]}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MoodChartData {
  final DateTime date;
  final int moodValue;
  final String? notes;

  MoodChartData({
    required this.date,
    required this.moodValue,
    this.notes,
  });
}
