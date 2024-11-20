import 'package:ezbooking_admin/core/utils/image_helper.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  int selectedIndex;
  final Function(int) onTabChange;
  Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  State<Sidebar> createState() => SidebarState();
}

class SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 3000),
      curve: Curves.ease,
      child: Container(
        color: const Color(0xFF1F2937), // Dark background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo and Brand
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageHelper.loadAssetImage(
                    'assets/images/logo.png', // Add your logo image
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Ez Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Menu Items
            _buildMenuItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              isActive: widget.selectedIndex == 0,
              onTap: () => widget.onTabChange(0),
            ),
            _buildMenuItem(
              icon: Icons.seventeen_mp_outlined,
              title: 'Management',
              isActive: widget.selectedIndex == 1,
              hasSubMenu: true,
              onTap: () {
                widget.onTabChange(1);
              },
            ),
            _buildMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              isActive: widget.selectedIndex == 2,
              onTap: () => widget.onTabChange(2),
            ),

            const Spacer(),

            // Bottom Summary Report Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669), // Green color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.summarize,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Report now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'EZ Booking Admin',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2024 All rights reserved',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    bool hasSubMenu = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? const Color(0xFF059669) : Colors.transparent,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: hasSubMenu
            ?  Icon(
                isActive ? Icons.arrow_drop_down_outlined : Icons.arrow_right,
                color: Colors.white70,
              )
            : null,
      ),
    );
  }
}
