import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/datasource/categories/category_datasource_impl.dart';
import 'package:ezbooking_admin/datasource/events/event_datasource.dart';
import 'package:ezbooking_admin/firebase_options.dart';
import 'package:ezbooking_admin/providers/categories/category_provider.dart';
import 'package:ezbooking_admin/providers/events/create_event_provider.dart';
import 'package:ezbooking_admin/providers/events/delete_event_provider.dart';
import 'package:ezbooking_admin/providers/events/update_event_provider.dart';
import 'package:ezbooking_admin/providers/organizers/organizer_provider.dart';
import 'package:ezbooking_admin/providers/statistics/statistic_provider.dart';
import 'package:ezbooking_admin/view/page/homepage.dart';
import 'package:ezbooking_admin/view/page/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => CategoryProvider(CategoryDatasourceImpl()),
    ),
    ChangeNotifierProvider(
      create: (_) => UpdateEventProvider(EventDatasource()),
    ),
    ChangeNotifierProvider(
      create: (_) => CreateEventProvider(EventDatasource()),
    ),
    ChangeNotifierProvider(
      create: (_) => DeleteEventProvider(EventDatasource()),
    ),
    ChangeNotifierProvider(create: (_) => OrganizerProvider()),
    ChangeNotifierProvider(create: (_) => StatisticProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final currentUser = FirebaseAuth.instance.currentUser;
  final homeKey = GlobalKey<HomepageState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ez Booking Admin Panel',
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.backgroundColor,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: child,
        );
      },
      child:
          currentUser == null ? const AdminLoginPage() : Homepage(key: homeKey),
    );
  }
}
