import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onTapMenu;

  const DashboardScreen({super.key, required this.onTapMenu});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = Breakpoints.isDesktop(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2D),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onTapMenu,
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search here',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildIconButton(Icons.notifications_outlined),
                const SizedBox(width: 16),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                    'https://png.pngtree.com/png-vector/20191101/ourmid/pngtree-cartoon-color-simple-male-avatar-png-image_1934459.jpg',
                  ),
                ),
              ],
            ),
            // Main Content
            Expanded(
              child: Padding(
                padding: isDesktop ? const EdgeInsets.all(16.0) : const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Top Cards Row
                            isDesktop ?
                              Row(
                                children: [
                                  Expanded(child: _buildTicketSoldCard()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildStatsCard()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildConversionCard()),
                                ],
                              ) : Column(
                              children: [
                                _buildTicketSoldCard(),
                                const SizedBox(height: 16),
                                _buildStatsCard(),
                                const SizedBox(height: 16),
                                _buildConversionCard(),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Charts Row
                            isDesktop ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildRevenueChart(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildBestSellingSection(),
                                ),
                              ],
                            ) : Column(
                              children: [
                                _buildRevenueChart(),
                                const SizedBox(height: 16),
                                _buildBestSellingSection(),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Bottom Section
                            isDesktop ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildLatestSales()),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: _buildRecentEventList(),
                                ),
                              ],
                            ) : Column(
                              children: [
                                _buildLatestSales(),
                                const SizedBox(height: 16),
                                _buildRecentEventList(),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.grey),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 300,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF171723),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search here',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
        const CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage('https://placekitten.com/100/100'),
        ),
      ],
    );
  }

  Widget _buildTicketSoldCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71),
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
          const Text(
            '456,502',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.arrow_upward, color: Colors.white, size: 16),
              const Text(
                '1.4%',
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text(
                      'View Details',
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

  Widget _buildStatsCard() {
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
            'Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(2.6, 2),
                      FlSpot(4.9, 5),
                      FlSpot(6.8, 3.1),
                      FlSpot(8, 4),
                      FlSpot(9.5, 3),
                      FlSpot(11, 4),
                    ],
                    isCurved: true,
                    color: const Color(0xFF2ECC71),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF2ECC71).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionCard() {
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
                'Increase 25%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: 8, color: const Color(0xFF2ECC71))
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: 10, color: const Color(0xFF2ECC71))
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: 6, color: const Color(0xFF2ECC71))
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(toY: 4, color: const Color(0xFF2ECC71))
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '2020',
                  style: TextStyle(color: Colors.white),
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
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}K',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 30),
                      FlSpot(2, 35),
                      FlSpot(4, 32),
                      FlSpot(6, 40),
                      FlSpot(8, 35),
                      FlSpot(10, 38),
                      FlSpot(11, 36),
                    ],
                    isCurved: true,
                    color: const Color(0xFF2ECC71),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF2ECC71).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellingSection() {
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
            'Best Selling',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: 15, color: const Color(0xFF2ECC71))
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: 8, color: const Color(0xFF2ECC71))
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: 12, color: const Color(0xFF2ECC71))
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(toY: 7, color: const Color(0xFF2ECC71))
                  ]),
                  BarChartGroupData(x: 4, barRods: [
                    BarChartRodData(toY: 10, color: const Color(0xFF2ECC71))
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestSales() {
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
                'Latest Sales',
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
          _buildSaleItem(
            name: 'Olivia Johnston',
            amount: '\$1,999.00',
            time: '5m ago',
          ),
          _buildSaleItem(
            name: 'Spiderman',
            amount: '\$699.00',
            time: '3m ago',
          ),
          _buildSaleItem(
            name: 'Doormat',
            amount: '\$999.00',
            time: '9m ago',
          ),
          _buildSaleItem(
            name: 'Lili Trump',
            amount: '\$399.00',
            time: '8m ago',
          ),
        ],
      ),
    );
  }

  Widget _buildSaleItem({
    required String name,
    required String amount,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF2ECC71),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
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
              image: const DecorationImage(
                image: AssetImage('assets/placeholder.jpg'),
                fit: BoxFit.cover,
              ),
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
