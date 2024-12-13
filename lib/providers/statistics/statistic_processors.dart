import 'dart:ui';

import 'package:ezbooking_admin/models/order.dart';
import 'package:ezbooking_admin/providers/statistics/statistic_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RevenueChartProcessor {
  /// Processes a list of statistics to generate revenue chart data for a specific year
  ///
  /// [statistics]: List of Statistic objects to process
  /// [year]: The year for which to generate the chart data
  /// Returns a list of FlSpot representing monthly revenues
  static List<FlSpot> processRevenueData(List<Order> orders, int year) {
    // Initialize a list to store monthly revenues, defaulting to 0
    List<double> monthlyRevenues = List.filled(12, 0.0);

    // Process each statistic to calculate monthly revenues
    for (var order in orders) {
      // Check if the order is from the specified year
      if (order.createdAt.toDate().year == year) {
        // Extract the month (0-based index)
        int month = order.createdAt.toDate().month - 1;

        // Add the total price of the order to the corresponding month
        monthlyRevenues[month] += (order.totalPrice) * 0.1;
      }
    }

    // Convert monthly revenues to FlSpots
    return monthlyRevenues.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value); // Convert to thousands
    }).toList();
  }

  /// Creates the LineChartBarData for the revenue chart
  ///
  /// [spots]: List of FlSpot representing monthly revenues
  /// Returns a LineChartBarData configured for the revenue visualization
  static LineChartBarData createRevenueChartBar(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: const Color(0xFF2ECC71),
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0xFF2ECC71).withOpacity(0.1),
      ),
    );
  }

  /// Example usage in a widget

}