import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/tasks/presentation/pages/tasks_page.dart';
import 'injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.init();
  runApp(const TodoRetroApp());
}

class TodoRetroApp extends StatelessWidget {
  const TodoRetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Injection.createThemeController()),
        ChangeNotifierProvider(
          create: (_) => Injection.createTasksViewModel()..load(),
        ),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'Pendientes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.from(context.palette),
          home: const TasksPage(),
        ),
      ),
    );
  }
}