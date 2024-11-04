import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/datasource/events/event_datasource.dart';
import 'package:ezbooking_admin/firebase_options.dart';
import 'package:ezbooking_admin/providers/events/create_event_provider.dart';
import 'package:ezbooking_admin/providers/events/delete_event_provider.dart';
import 'package:ezbooking_admin/providers/events/fetch_events_provider.dart';
import 'package:ezbooking_admin/providers/events/update_event_provider.dart';
import 'package:ezbooking_admin/view/page/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => FetchEventsProvider(EventDatasource()),
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
        ],
        child: const Homepage(),
      ),
    );
  }
}
