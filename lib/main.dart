import 'package:flutter/material.dart';
import 'package:google_map_integration_tool/integration_tool_screen.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    minimumSize: Size(800, 600),
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Flutter Package Integrator',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(IntegrationToolApp());
}

class IntegrationToolApp extends StatelessWidget {
  const IntegrationToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: IntegrationToolScreen());
  }
}
