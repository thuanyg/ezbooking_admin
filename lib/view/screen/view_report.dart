import 'dart:io';

import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/models/order.dart';
import 'package:ezbooking_admin/providers/statistics/statistic_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class StatisticsSummaryPage extends StatefulWidget {
  const StatisticsSummaryPage({super.key});

  @override
  State<StatisticsSummaryPage> createState() => _StatisticsSummaryPageState();
}

class _StatisticsSummaryPageState extends State<StatisticsSummaryPage> {
  late StatisticProvider statisticProvider;

  @override
  void initState() {
    super.initState();
    statisticProvider = Provider.of<StatisticProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      statisticProvider.fetchOrders();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Summary'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: Consumer<StatisticProvider>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Calculate summary metrics
          final totalRevenue = _calculateTotalRevenue(value.orders);
          final totalTicketsSold = _calculateTotalTicketsSold(value.orders);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Summary Cards
                  _buildOverviewCards(totalRevenue, totalTicketsSold),

                  SizedBox(height: 20),

                  // Event Distribution Chart
                  // _buildEventDistributionChart(eventCounts),

                  SizedBox(height: 20),

                  // Revenue by Event Chart
                  // _buildRevenueByEventChart(revenueByEvent),

                  SizedBox(height: 20),

                  // Detailed Statistics Table
                  // _buildDetailedStatisticsTable(value.statistics),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Calculate total revenue across all statistics
  double _calculateTotalRevenue(List<Order> orders) {
    return orders.fold(0.0, (sum, order) => sum + (order.totalPrice * 0.1));
  }

  // Calculate total tickets sold
  int _calculateTotalTicketsSold(List<Order> orders) {
    return orders.fold(0, (sum, order) => sum + order.ticketQuantity);
  }


  // Overview Cards Widget
  Widget _buildOverviewCards(double totalRevenue, int totalTicketsSold) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 5,
            color: AppColors.drawerColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.monetization_on,
                      color: Colors.green, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'Total Revenue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(totalRevenue),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 5,
            color: AppColors.drawerColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.confirmation_number,
                      color: Colors.blue, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'Total Tickets Sold',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    totalTicketsSold.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Event Distribution Pie Chart
  Widget _buildEventDistributionChart(Map<String, int> eventCounts) {
    return Card(
      elevation: 5,
      color: AppColors.drawerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ticket Sales by Event',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SfCircularChart(
              legend: const Legend(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white),
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              series: <CircularSeries>[
                PieSeries<MapEntry<String, int>, String>(
                  dataSource: eventCounts.entries.toList(),
                  xValueMapper: (entry, _) => entry.key,
                  yValueMapper: (entry, _) => entry.value,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(color: Colors.white),
                    labelPosition: ChartDataLabelPosition.outside,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Revenue by Event Chart
  Widget _buildRevenueByEventChart(Map<String, double> revenueByEvent) {
    return Card(
      elevation: 5,
      color: AppColors.drawerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue by Event',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SfCartesianChart(
              primaryXAxis: const CategoryAxis(
                labelStyle: TextStyle(color: Colors.white),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.white),
                labelFormat: '{value}',
                numberFormat: NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0),
              ),
              series: <CartesianSeries>[
                ColumnSeries<MapEntry<String, double>, String>(
                  color: AppColors.primaryColor,
                  dataSource: revenueByEvent.entries.toList(),
                  xValueMapper: (entry, _) => entry.key,
                  yValueMapper: (entry, _) => entry.value,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(color: Colors.white),
                    labelPosition: ChartDataLabelPosition.outside,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Detailed Statistics Table
  Widget _buildDetailedStatisticsTable(List<Order> statistics) {
    return Card(
      elevation: 5,
      color: AppColors.drawerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                      label: Text(
                    'Event',
                    style: TextStyle(color: Colors.white70),
                  )),
                  DataColumn(
                      label: Text(
                    'Tickets Sold',
                    style: TextStyle(color: Colors.white70),
                  )),
                  DataColumn(
                      label: Text(
                    'Revenue',
                    style: TextStyle(color: Colors.white70),
                  )),
                  DataColumn(
                      label: Text(
                    'Date Create',
                    style: TextStyle(color: Colors.white70),
                  )),
                ],
                rows: statistics
                    .map((stat) => DataRow(cells: [
                          DataCell(Text(
                            "stat.event.name",
                            style: const TextStyle(color: Colors.white70),
                          )),
                          DataCell(Text(
                            "1",
                            style: const TextStyle(color: Colors.white70),
                          )),
                          DataCell(Text(
                            // NumberFormat.currency(symbol: '\$')
                            //     .format(stat.order.totalPrice),
                            "12",
                            style: const TextStyle(color: Colors.white70),
                          )),
                          DataCell(Text(
                              // DateFormat('yyyy-MM-dd')
                              //     .format(stat.order.createdAt.toDate()),
                            "1",
                              style: const TextStyle(color: Colors.white70))),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Note: You'll need to add these dependencies to your pubspec.yaml:
// - intl: ^0.18.0
// - syncfusion_flutter_charts: ^21.1.38
