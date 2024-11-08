import 'package:ezbooking_admin/core/configs/app_colors.dart';
import "dart:html" as html;
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/view/screen/customer.dart';
import 'package:ezbooking_admin/view/screen/dashboard.dart';
import 'package:ezbooking_admin/view/screen/event.dart';
import 'package:ezbooking_admin/view/screen/settings.dart';
import 'package:ezbooking_admin/view/widgets/header.dart';
import 'package:ezbooking_admin/view/widgets/side_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isSidebarVisible = true;
  int tabSelectedIndex = 1;

  // Function to change the screen and update the URL
  void onTabSelected(int index) {
    if (Breakpoints.isMobile(context)) {
      Navigator.of(context).pop();
    }

    setState(() {
      tabSelectedIndex = index;
    });

    // Update the URL in the browser
    switch (index) {
      case 0:
        _updateUrl('/'); // Dashboard
        break;
      case 1:
        _updateUrl('/event'); // Event Screen
        break;
      case 2:
        _updateUrl('/customer'); // Customer Screen
        break;
      case 3:
        _updateUrl('/settings'); // Settings Screen
        break;
    }
  }

  // Method to change the URL without a page reload
  void _updateUrl(String url) {
    // Using HTML5 history API
    // This requires `dart:html` import
    // ignore: unnecessary_import
    html.window.history.pushState(null, '', url);
  }

  void toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
  }

  void onTapMenu(BuildContext context) {
    if (Breakpoints.isDesktop(context)) {
      toggleSidebar();
    } else {
      final scaffold = Scaffold.of(context);
      if (scaffold.hasDrawer) {
        scaffold.openDrawer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    List<Widget> screens = [
      Builder(
        builder: (context) => DashboardScreen(
          onTapMenu: () => onTapMenu(context),
        ),
      ),
      EventScreen(),
      CustomerScreen(),
      SettingScreen(),
    ];

    return Scaffold(
      drawer: isDesktop
          ? null
          : Drawer(
              child: Sidebar(
                selectedIndex: tabSelectedIndex,
                onTabChange: (index) => onTabSelected(index),
              ),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop && isSidebarVisible)
              Flexible(
                flex: 2,
                child: Sidebar(
                  selectedIndex: tabSelectedIndex,
                  onTabChange: (index) => onTabSelected(index),
                ),
              ),
            Flexible(
              flex: 8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Header(
                      onTapMenu: (ctx) => onTapMenu(ctx),
                    ),
                  ),
                  Expanded(child: screens[tabSelectedIndex]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
