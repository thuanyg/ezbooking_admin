import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/models/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RevenueSyncfusionChart extends StatelessWidget {
  final List<Order> orders;
  final ValueNotifier<String> filterYear;

  const RevenueSyncfusionChart({
    Key? key,
    required this.orders,
    required this.filterYear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderSuccess = orders.where((o)=>o.status == "success").toList();
    final revenueData =
        _processRevenueData(orderSuccess, int.parse(filterYear.value));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171723),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(context),
          const SizedBox(height: 16),
          _buildSyncfusionChart(revenueData),
        ],
      ),
    );
  }

  Widget _buildChartHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Sales Revenue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildYearDropdown(context),
      ],
    );
  }

  Widget _buildYearDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (selectedYear) {
        filterYear.value = selectedYear;
      },
      itemBuilder: (context) => _buildYearMenuItems(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF171723),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          filterYear.value,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildYearMenuItems() {
    return ['2024', '2023', '2022']
        .map((year) => PopupMenuItem<String>(
              value: year,
              child: Text(year),
            ))
        .toList();
  }

  Widget _buildSyncfusionChart(List<RevenueData> revenueData) {
    return SizedBox(
      height: 250,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          numberFormat: NumberFormat.currency(symbol: '\$'),
          majorGridLines: MajorGridLines(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        plotAreaBorderWidth: 0,
        series: <CartesianSeries<RevenueData, String>>[
          SplineAreaSeries<RevenueData, String>(
            dataSource: revenueData,
            xValueMapper: (RevenueData revenue, _) => revenue.month,
            yValueMapper: (RevenueData revenue, _) => revenue.sales,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                const Color(0xFF5B94D6).withOpacity(0.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderGradient: LinearGradient(
              colors: [AppColors.primaryColor, Color(0xFF5B94D6)],
            ),
            borderWidth: 2,
          ),
        ],
      ),
    );
  }

  List<RevenueData> _processRevenueData(List<Order> orders, int year) {
    // Similar to previous data processing logic
    final monthlyRevenue = List.filled(12, 0.0);

    for (var order in orders) {
      if (order.createdAt.toDate().year == year) {
        monthlyRevenue[order.createdAt.toDate().month - 1] +=
            (order.ticketPrice * order.ticketQuantity * 0.1);
      }
    }

    return List.generate(
        12,
        (index) => RevenueData(
              _getMonthName(index),
              monthlyRevenue[index],
            ));
  }

  String _getMonthName(int index) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[index];
  }
}

// Supporting data classes
class RevenueData {
  final String month;
  final double sales;

  RevenueData(this.month, this.sales);
}

// -------------------------------


class OrderStatusPieChart extends StatefulWidget {
  final List<Order> orders;

  const OrderStatusPieChart({
    Key? key,
    required this.orders,
  }) : super(key: key);

  @override
  _OrderStatusPieChartState createState() => _OrderStatusPieChartState();
}

class _OrderStatusPieChartState extends State<OrderStatusPieChart> {
  late List<OrderStatusData> orderStatusData;
  late List<OrderStatusData> displayedData;

  @override
  void initState() {
    super.initState();
    orderStatusData = _processOrderStatusData(widget.orders);
    displayedData = List.from(orderStatusData);  // Initially show all data
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171723),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSyncfusionPieChart(),
          _buildPieChartLegend(),
        ],
      ),
    );
  }

  Widget _buildSyncfusionPieChart() {
    return SizedBox(
      height: 250,
      child: SfCircularChart(
        series: <CircularSeries>[
          PieSeries<OrderStatusData, String>(
            dataSource: displayedData,
            xValueMapper: (OrderStatusData statusData, _) => statusData.status,
            yValueMapper: (OrderStatusData statusData, _) => statusData.count,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            pointColorMapper: (OrderStatusData statusData, _) {
              switch (statusData.status) {
                case 'Success':
                  return AppColors.primaryColor;
                case 'Pending':
                  return const Color(0xFFF5A623);
                case 'Cancelled':
                  return const Color(0xFF9B9B9B);
                default:
                  return Colors.grey;
              }
            },
            radius: '80%',
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: orderStatusData.map((statusData) {
        return GestureDetector(
          onTap: () {
            setState(() {
              // Toggle visibility
              if (displayedData.contains(statusData)) {
                displayedData.remove(statusData);
              } else {
                displayedData.add(statusData);
              }
            });
          },
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: _getColorForStatus(statusData.status),
              ),
              const SizedBox(width: 8),
              Text(
                statusData.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Success':
        return AppColors.primaryColor;
      case 'Pending':
        return const Color(0xFFF5A623);
      case 'Cancelled':
        return const Color(0xFF9B9B9B);
      default:
        return Colors.grey;
    }
  }

  List<OrderStatusData> _processOrderStatusData(List<Order> orders) {
    final orderStatusCount = <String, int>{
      'Success': 0,
      'Pending': 0,
      'Cancelled': 0,
    };

    for (var order in orders) {
      if (order.status == 'success') {
        orderStatusCount['Success'] = orderStatusCount['Success']! + 1;
      } else if (order.status == 'pending') {
        orderStatusCount['Pending'] = orderStatusCount['Pending']! + 1;
      } else if (order.status == 'cancelled') {
        orderStatusCount['Cancelled'] = orderStatusCount['Cancelled']! + 1;
      }
    }

    return [
      OrderStatusData('Success', orderStatusCount['Success']!),
      OrderStatusData('Pending', orderStatusCount['Pending']!),
      OrderStatusData('Cancelled', orderStatusCount['Cancelled']!),
    ];
  }
}

class OrderStatusData {
  final String status;
  final int count;

  OrderStatusData(this.status, this.count);
}

