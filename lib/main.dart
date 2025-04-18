import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_managment/controller/habits_cubit/habit_cubit.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/core/router.dart';
import 'package:tasks_managment/services/habit_storage_service.dart';
import 'package:tasks_managment/services/notification_service.dart';

// تعريف المتغير العالمي لـ HabitCubit، وإضافة قيمة افتراضية لتجنب الخطأ
HabitCubit? _habitCubit;
// دالة للحصول على المتغير، ستقوم بإنشاء نسخة جديدة إذا لم تكن موجودة
HabitCubit getHabitCubit() {
  _habitCubit ??= HabitCubit();
  return _habitCubit!;
}

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

    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.init();

    // تهيئة HabitCubit العالمي
    _habitCubit = HabitCubit(
      storageService: habitStorageService,
      notificationService: notificationService,
    );

    // Schedule daily reminder for habit tracking
    await notificationService.scheduleDailyHabitReminder(
      id: 1,
      title: 'Habit Reminder',
      body: 'Time to check your daily habits!',
      time: const TimeOfDay(hour: 20, minute: 0), // 8:00 PM
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(
      MyApp(
        habitStorageService: habitStorageService,
        notificationService: notificationService,
      ),
    );
  } catch (e) {
    // معالجة الأخطاء الرئيسية في التهيئة
    debugPrint("Error during initialization: $e");

    // تشغيل التطبيق على أي حال مع خدمة تخزين جديدة
    final habitStorageService = HabitStorageService();
    final notificationService = NotificationService();
    _habitCubit = HabitCubit(
      storageService: habitStorageService,
      notificationService: notificationService,
    );

    runApp(
      MyApp(
        habitStorageService: habitStorageService,
        notificationService: notificationService,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final HabitStorageService habitStorageService;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.habitStorageService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<HabitCubit>.value(value: getHabitCubit())],
      child: MaterialApp.router(
        title: 'Task Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        routerConfig: appRouter,
      ),
    );
  }
}
