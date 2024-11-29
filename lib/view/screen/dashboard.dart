import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/providers/statistics/statistic_processors.dart';
import 'package:ezbooking_admin/providers/statistics/statistic_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ValueNotifier<String> filterYear = ValueNotifier(2024.toString());

  late StatisticProvider statisticProvider;

  @override
  void initState() {
    statisticProvider = Provider.of<StatisticProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      statisticProvider.fetchStatistics();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isDesktop = Breakpoints.isDesktop(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<StatisticProvider>(
        builder: (context, value, child) {

          // Calculate summary metrics
          final totalRevenue = _calculateTotalRevenue(value.statistics);
          final totalTicketsSold = _calculateTotalTicketsSold(value.statistics);
          final eventCounts = _calculateEventCounts(value.statistics);
          final revenueByEvent = _calculateRevenueByEvent(value.statistics);

          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // Main Content
                Expanded(
                  child: Padding(
                    padding: isDesktop
                        ? const EdgeInsets.all(16.0)
                        : const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildTicketSoldCard(
                                  statisticProvider,
                                  context,
                                ),
                                const SizedBox(height: 24),
                                _buildOverviewCards(totalRevenue, totalTicketsSold),
                                const SizedBox(height: 24),
                                // Charts Row
                                ValueListenableBuilder(
                                  valueListenable: filterYear,
                                  builder: (context, value, child) =>
                                      buildRevenueChart(
                                          statisticProvider.statistics),
                                ),
                                const SizedBox(height: 24),
                                _buildRevenueByEventChart(revenueByEvent),
                                // Bottom Section
                                // _buildRecentEventList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  // Calculate total revenue across all statistics
  double _calculateTotalRevenue(List<Statistic> statistics) {
    return statistics.fold(0.0, (sum, stat) => sum + (stat.order.totalPrice * 0.1));
  }

  // Calculate total tickets sold
  int _calculateTotalTicketsSold(List<Statistic> statistics) {
    return statistics.fold(0, (sum, stat) => sum + stat.order.ticketQuantity);
  }

  // Calculate event counts
  Map<String, int> _calculateEventCounts(List<Statistic> statistics) {
    final Map<String, int> eventCounts = {};
    for (var stat in statistics) {
      eventCounts[stat.event.name] =
          (eventCounts[stat.event.name] ?? 0) + stat.order.ticketQuantity;
    }
    return eventCounts;
  }

  // Calculate revenue by event
  Map<String, double> _calculateRevenueByEvent(List<Statistic> statistics) {
    final Map<String, double> revenueByEvent = {};
    for (var stat in statistics) {
      revenueByEvent[stat.event.name] =
          (revenueByEvent[stat.event.name] ?? 0) + (stat.order.totalPrice * 0.1);
    }
    return revenueByEvent;
  }

  // Overview Cards Widget
  Widget _buildOverviewCards(double totalRevenue, int totalTicketsSold) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 5,
            color: const Color(0xFF171723),
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
            color: const Color(0xFF171723),
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


  Widget _buildTicketSoldCard(
      StatisticProvider provider, BuildContext context) {
    final orders = provider.getOrders(provider.statistics);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171723),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ticket Sold Today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.calculateTicketToday(orders).toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await showOrderListBottomSheet(provider.statistics, context);
                },
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueByEventChart(Map<String, double> revenueByEvent) {
    return Card(
      elevation: 5,
      color: const Color(0xFF171723),
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

  Future<void> showOrderListBottomSheet(
      List<Statistic> statistics, BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.drawerColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Center(
                child: Text(
                  'Ticket Order List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Divider
              const Divider(color: Colors.grey),

              // Expandable list of orders
              Expanded(
                child: OrderTicketList(statistics: statistics),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildRevenueChart(List<Statistic> statistics) {
    // Process revenue data for the year 2020
    final revenueSpots = RevenueChartProcessor.processRevenueData(
        statistics, int.parse(filterYear.value));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171723),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sales Revenue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (selectedYear) {
                  // Handle the year selection logic here
                  filterYear.value = selectedYear;
                },
                itemBuilder: (context) {
                  return <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: '2024',
                      child: Text('2024'),
                    ),
                    const PopupMenuItem<String>(
                      value: '2023',
                      child: Text('2023'),
                    ),
                    const PopupMenuItem<String>(
                      value: '2022',
                      child: Text('2022'),
                    ),
                  ];
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    filterYear.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
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
                        int index = value.toInt();
                        return Text(
                         months[index],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  RevenueChartProcessor.createRevenueChartBar(revenueSpots)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEventList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171723),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Event List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEventItem(
            title: 'The Story of Danau Toba (Musical Drama)',
            author: 'Medan, Indonesia',
            price: '\$120.00',
            date: '20 June 2020',
            imageUrl: 'placeholder.jpg',
          ),
          _buildEventItem(
            title: 'Indie Band Festivals Jakarta 2020',
            author: 'Jakarta, Indonesia',
            price: '\$150.00',
            date: '25 June 2020',
            imageUrl: 'placeholder.jpg',
          ),
          _buildEventItem(
            title: 'International Live Choir Festivals 2020',
            author: 'Medan, Indonesia',
            price: '\$180.00',
            date: '29 June 2020',
            imageUrl: 'placeholder.jpg',
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem({
    required String title,
    required String author,
    required String price,
    required String date,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF2ECC71),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderTicketList extends StatelessWidget {
  final List<Statistic> statistics;

  const OrderTicketList({Key? key, required this.statistics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid count based on screen width
        int crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 800
                ? 2
                : 1;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: statistics.length,
            itemBuilder: (context, index) {
              return OrderTicketCard(
                statistic: statistics[index],
              );
            },
          ),
        );
      },
    );
  }
}

class OrderTicketCard extends StatelessWidget {
  final Statistic statistic;

  const OrderTicketCard({super.key, required this.statistic});

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1E2D),
            Color(0xFF171723),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background pattern or texture

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${statistic.order.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(statistic.order.status)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statistic.order.status,
                          style: TextStyle(
                            color: _getStatusColor(statistic.order.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Event and Ticket Details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Customer: ${statistic.user.fullName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Event: ${statistic.event.name}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Organizer: ${statistic.organizer.name}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${statistic.order.ticketQuantity} Ticket(s)',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Price: \$${statistic.ticket.ticketPrice}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Created Date: ${DateFormat('MMM dd, yyyy').format(statistic.order.createdAt.toDate())}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Footer with Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '\$${statistic.order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deduction',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '10%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Organizer receive:',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '\$${(statistic.order.totalPrice * 0.9).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'EzBooking receive:',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$${(statistic.order.totalPrice * 0.1).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
