import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/models/order.dart';
import 'package:ezbooking_admin/providers/events/fetch_event_provider.dart';
import 'package:ezbooking_admin/providers/statistics/statistic_processors.dart';
import 'package:ezbooking_admin/providers/statistics/statistic_provider.dart';
import 'package:ezbooking_admin/view/widgets/syncfusion_flutter_charts.dart';
import 'package:ezbooking_admin/view/widgets/table.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
      if (statisticProvider.orders.isEmpty) {
        statisticProvider.fetchOrders();
      }
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
          final totalRevenue = _calculateTotalRevenue(value.orders);
          final totalTicketsSold = _calculateTotalTicketsSold(value.orders);

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
                                _buildOverviewCards(
                                    totalRevenue, totalTicketsSold),
                                const SizedBox(height: 24),
                                // Charts Row
                                ValueListenableBuilder(
                                  valueListenable: filterYear,
                                  builder: (context, value, child) =>
                                      RevenueSyncfusionChart(
                                          filterYear: filterYear,
                                          orders: statisticProvider.orders),
                                ),

                                OrderStatusPieChart(
                                    orders: statisticProvider.orders),
                                const SizedBox(height: 24),
                                EventStatisticsTable(
                                    orders: statisticProvider.orders),
                                // _buildRevenueByEventChart(revenueByEvent),
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
  double _calculateTotalRevenue(List<Order> orders) {
    return orders
        .where((o) => o.status == "success")
        .fold(0.0, (sum, order) => sum + (order.totalPrice * 0.1));
  }

  // Calculate total tickets sold
  int _calculateTotalTicketsSold(List<Order> orders) {
    return orders
        .where((o) => o.status == "success")
        .fold(0, (sum, order) => sum + order.ticketQuantity);
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
    int totalTicketSoldToday = provider.countTicketsSoldToday(provider.orders);
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
            totalTicketSoldToday.toString(),
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
                  await showOrderListBottomSheet(context, provider.orders);
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
                numberFormat: NumberFormat.currency(
                    locale: 'en_US', symbol: '\$', decimalDigits: 0),
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
      BuildContext context, List<Order> orders) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.drawerColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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

                // Tabs
                TabBar(
                  labelColor: AppColors.primaryColor,
                  indicatorColor: AppColors.primaryColor,
                  dividerHeight: .1,
                  unselectedLabelColor: Colors.white,
                  onTap: (value) {},
                  tabs: const [
                    Tab(text: "Success"),
                    Tab(text: "Pending"),
                    Tab(text: "Cancelled"),
                  ],
                ),
                // TabBarView with IndexedStack
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final tabController = DefaultTabController.of(context)!;
                      return AnimatedBuilder(
                        animation: tabController,
                        builder: (context, _) {
                          return IndexedStack(
                            index: tabController.index,
                            children: [
                              OrderTicketList(
                                status: "success",
                                orders: orders,
                              ),
                              OrderTicketList(
                                status: "pending",
                                orders: orders,
                              ),
                              OrderTicketList(
                                status: "cancelled",
                                orders: orders,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildRevenueChart(List<Order> orders) {
    // Process revenue data for the year
    final revenueSpots = RevenueChartProcessor.processRevenueData(
        orders, int.parse(filterYear.value));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33), // Darker background for contrast
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold, // Bolder text
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
                    color: const Color(0xFF2D2E3F),
                    // Slightly different color for the button
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
            height: 250, // Increased chart height for better visibility
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.2),
                      // Lighter grid lines
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
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14, // Larger font size
                            fontWeight: FontWeight.bold, // Bolder text
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
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14, // Larger font size
                            fontWeight: FontWeight.bold, // Bolder text
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
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    // Soft border for the chart
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  // Apply a gradient color to the line for a sleek effect
                  LineChartBarData(
                    spots: revenueSpots,
                    isCurved: true,
                    color: Color(0xFF4C72B0),
                    // Gradient colors
                    dotData: FlDotData(show: false),
                    belowBarData:
                        BarAreaData(show: true, color: Color(0xFF4C72B0)),
                    aboveBarData: BarAreaData(show: false),
                  ),
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
  final String status;
  final List<Order> orders;

  const OrderTicketList(
      {super.key, required this.status, required this.orders});

  @override
  Widget build(BuildContext context) {
    final ordersFiltered = orders.where((o) => o.status == status).toList();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        itemCount: ordersFiltered.length,
        itemBuilder: (context, index) {
          return OrderTicketCard(order: ordersFiltered[index]);
        },
      ),
    );
  }
}

class OrderTicketCard extends StatelessWidget {
  final Order order;

  const OrderTicketCard({super.key, required this.order});

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
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

  void _showOrderDetailsBottomSheet(BuildContext context, Order order) {
    final eventProvider =
        Provider.of<FetchEventProvider>(context, listen: false);
    eventProvider.fetchEventById(order.eventID);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        shouldCloseOnMinExtent: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Consumer<FetchEventProvider>(
            builder: (context, value, child) {
              if (value.isLoading) {
                return Center(
                  child: Lottie.asset(
                    "assets/animations/loading.json",
                    height: 60,
                  ),
                );
              }
              if (value.event != null) {
                final event = value.event;
                return ListView(
                  controller: scrollController,
                  children: [
                    // Header
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Status and Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailChip(
                          icon: Icons.check_circle_outline,
                          label: 'Status',
                          value: order.status.toUpperCase(),
                          color: _getStatusColor(order.status),
                        ),
                        _buildDetailChip(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: DateFormat('dd MMM yyyy\nHH:mm')
                              .format(order.createdAt.toDate()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Event Information Section
                    _buildSectionTitle('Event Details'),
                    const SizedBox(height: 10),
                    _buildDetailRow('Event Name', event?.name ?? ""),
                    _buildDetailRow(
                        'Event Date',
                        DateFormat('dd MMM yyyy, HH:mm')
                            .format(event?.date ?? DateTime.now())),
                    _buildDetailRow('Location', event?.location ?? ""),
                    _buildDetailRow('Event Type', event?.eventType ?? ""),

                    // Order Details Section
                    const SizedBox(height: 20),
                    _buildSectionTitle('Order Details'),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      'Tickets Booked',
                      '${order.ticketQuantity} x ${NumberFormat.currency(symbol: '\$').format(order.ticketPrice)}',
                    ),
                    _buildDetailRow(
                      'Total Amount',
                      NumberFormat.currency(symbol: '\$')
                          .format(order.ticketQuantity * order.ticketPrice),
                    ),
                    if (order.discount != null)
                      _buildDetailRow(
                        'Discount',
                        NumberFormat.currency(symbol: '\$')
                            .format(order.discount!),
                      ),

                    // Payment Information
                    const SizedBox(height: 20),
                    _buildSectionTitle('Payment Information'),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                        'Payment Method', order.paymentMethod ?? 'VNPay'),
                    _buildDetailRow('Order Type', order.orderType),
                    _buildDetailRow('Payment ID', order.id ?? 'N/A'),

                    const SizedBox(height: 30),
                    // Close Button
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // Helper method to build detail chips
  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
    Color color = Colors.grey,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

// Helper method to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white60,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showOrderDetailsBottomSheet(context, order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                          'Order #${order.id}',
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
                            color:
                                _getStatusColor(order.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: _getStatusColor(order.status),
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
                        Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${order.ticketQuantity} Ticket(s)',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Price: \$${order.ticketPrice}',
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
                              DateFormat('MMM dd, yyyy')
                                  .format(order.createdAt.toDate()),
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
                          '\$${order.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
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
                            fontSize: 15,
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
                          '\$${(order.totalPrice * 0.9).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EzBooking receive:',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${(order.totalPrice * 0.1).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 15,
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
      ),
    );
  }
}
