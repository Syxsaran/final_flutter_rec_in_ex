import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildExpenseIncomeChart(List<QueryDocumentSnapshot> docs) {
  List<BarChartGroupData> barGroups = [];
  Map<String, double> incomePerMonth = {};
  Map<String, double> expensePerMonth = {};

  // Group income and expenses by month
  for (var doc in docs) {
    DateTime date = (doc['date'] as Timestamp).toDate();
    String monthKey = DateFormat('MMM yyyy').format(date);

    double amount = doc['amount'];
    String type = doc['type'];

    if (type == 'รายรับ') {
      incomePerMonth.update(monthKey, (value) => value + amount,
          ifAbsent: () => amount);
    } else {
      expensePerMonth.update(monthKey, (value) => value + amount,
          ifAbsent: () => amount);
    }
  }

  // Prepare data for each month
  for (var entry in incomePerMonth.entries) {
    double income = entry.value;
    double expense = expensePerMonth[entry.key] ?? 0.0;

    barGroups.add(
      BarChartGroupData(
        x: barGroups.length,
        barRods: [
          BarChartRodData(
            toY: income,
            color: Colors.green,
            width: 20, // Adjust width as necessary
          ),
          BarChartRodData(
            toY: expense,
            color: Colors.red,
            width: 20, // Adjust width as necessary
          ),
        ],
      ),
    );
  }

  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(incomePerMonth.keys.elementAt(value.toInt()));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString());
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      barGroups: barGroups,
    ),
  );
}
