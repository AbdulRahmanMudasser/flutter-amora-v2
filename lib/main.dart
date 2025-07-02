import 'dart:io';

import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/data/models/user_model.dart';
import 'package:amora/features/dashboard/data/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'features/authentication/presentation/screens/splash_screen.dart'; // Import the SplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for user data
  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<TaskModel>('tasks');

  // Create memories directory for image storage
  final memoriesDir = Directory('${directory.path}/memories');
  if (!await memoriesDir.exists()) {
    await memoriesDir.create(recursive: true);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amora',
      theme: AppTheme.lightTheme,
      builder: AppTheme.romanticTransitionBuilder,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ur', ''), // Urdu
      ],
      home: const SplashScreen(), // Set SplashScreen as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}