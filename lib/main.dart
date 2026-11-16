import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/presentation/pages/tasks_page.dart';
import 'features/tasks/presentation/viewmodels/tasks_view_model.dart';
import 'injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ya no se espera Injection.init() aqui: se pinta la app de inmediato
  // y la carga real ocurre dentro de _Bootstrap, con una pantalla propia
  // en vez de depender del splash nativo (que se ve negro liso).
  runApp(const TodoRetroApp());
}

class TodoRetroApp extends StatelessWidget {
  const TodoRetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendientes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.from(AppPalettes.wii),
      home: const _Bootstrap(),
    );
  }
}

/// Pantalla minima que se ve mientras Injection.init() resuelve
/// SharedPreferences. Usa la paleta por defecto porque el tema real
/// todavia no esta disponible en este punto.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late final Future<void> _ready = Injection.init();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => Injection.createThemeController(),
            ),
            ChangeNotifierProvider(
              create: (_) => Injection.createLanguageController(),
            ),
            ChangeNotifierProvider(
              create: (_) => Injection.createTasksViewModel()..load(),
            ),
            // Las misiones escuchan a las tareas, por eso van despues.
            ChangeNotifierProvider(
              create: (context) => Injection.createMissionsViewModel(
                context.read<TasksViewModel>(),
              )..load(),
            ),
          ],
          child: Builder(
            builder: (context) => MaterialApp(
              title: 'Pendientes',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.from(context.palette),
              // Tope al tamano de letra del sistema: mas alla de 1.3x las
              // piezas de la interfaz ya no caben y se desbordan.
              builder: (context, child) => MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: child!,
              ),
              home: const TasksPage(),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    const p = AppPalettes.wii;

    return Scaffold(
      backgroundColor: p.panel,
      body: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(p.accent),
          ),
        ),
      ),
    );
  }
}
