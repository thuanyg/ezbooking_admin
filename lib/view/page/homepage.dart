import "dart:html" as html;
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/view/screen/dashboard.dart';
import 'package:ezbooking_admin/view/screen/management.dart';
import 'package:ezbooking_admin/view/screen/search_result.dart';
import 'package:ezbooking_admin/view/widgets/header.dart';
import 'package:ezbooking_admin/view/widgets/side_bar.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  bool isSidebarVisible = true;
  int tabSelectedIndex = 0;
  String? searchQuery;
  final GlobalKey<SidebarState> sideBarKey = GlobalKey<SidebarState>();

  ValueNotifier<bool> isSearchResult = ValueNotifier(false);

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
      const DashboardScreen(),
      Management(sideBarKey: sideBarKey),
    ];

    return Scaffold(
      drawer: Visibility(
        visible: !isDesktop,
        child: Drawer(
          child: Sidebar(
            key: sideBarKey,
            selectedIndex: tabSelectedIndex,
            onTabChange: (index) => onTabSelected(index),
          ),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            Visibility(
              visible: isDesktop && isSidebarVisible,
              child: Flexible(
                flex: 2,
                child: Sidebar(
                  key: sideBarKey,
                  selectedIndex: tabSelectedIndex,
                  onTabChange: (index) {
                    isSearchResult.value = false;
                    onTabSelected(index);
                  },
                ),
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
                      homeKey: widget.key as GlobalKey<HomepageState>,
                      onTapMenu: (ctx) => onTapMenu(ctx),
                    ),
                  ),
                  Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: isSearchResult,
                        builder: (context, value, child) {
                          return value
                              ? SearchResult(
                            query: searchQuery ?? "",
                            homeKey: widget.key as GlobalKey<HomepageState>,
                          )
                              : screens[tabSelectedIndex];
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
