import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/tasks/presentation/pages/tasks_page.dart';
import 'injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const TodoRetroApp());
}

class TodoRetroApp extends StatelessWidget {
  const TodoRetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Injection.createTasksViewModel()..load(),
      child: MaterialApp(
        title: 'Pendientes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const TasksPage(),
      ),
    );
  }
}