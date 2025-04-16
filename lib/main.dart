import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_managment/controller/habits_cubit/habit_cubit.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/screens/onboarding_screen.dart';
import 'package:tasks_managment/services/habit_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // تهيئة Hive للتخزين المحلي
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // تهيئة خدمة التخزين (المحولات سيتم تسجيلها داخل الخدمة)
    final habitStorageService = HabitStorageService();
    await habitStorageService.init();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(MyApp(habitStorageService: habitStorageService));
  } catch (e) {
    // معالجة الأخطاء الرئيسية في التهيئة
    debugPrint("Error during initialization: $e");

    // تشغيل التطبيق على أي حال مع خدمة تخزين جديدة
    runApp(MyApp(habitStorageService: HabitStorageService()));
  }
}

class MyApp extends StatelessWidget {
  final HabitStorageService habitStorageService;

  const MyApp({super.key, required this.habitStorageService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HabitCubit>(
          create: (context) => HabitCubit(storageService: habitStorageService),
        ),
      ],
      child: MaterialApp(
        title: 'Task Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: const OnboardingScreen(),
      ),
    );
  }
}
