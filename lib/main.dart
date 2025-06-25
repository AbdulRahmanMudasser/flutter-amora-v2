import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/data/models/user_model.dart';
import 'package:amora/features/authentication/presentation/screens/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('users');
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
      home: const RegistrationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
