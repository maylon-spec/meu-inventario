import 'package:flutter/material.dart';
import 'package:meu_inventario/services/inventory_database.dart';
import 'package:meu_inventario/services/sync_service.dart';
import 'package:meu_inventario/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // O app funciona localmente mesmo antes da configuraÃ§Ã£o do Firebase.
  // Para ativar a nuvem, configure FlutterFire e descomente a inicializaÃ§Ã£o.
  bool cloudConfigured = false;
  try {
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    // cloudConfigured = true;
  } catch (e) {
    debugPrint('Firebase ainda nÃ£o configurado: $e');
  }

  await InventoryDatabase.instance.database;
  SyncService.instance.configure(enabled: cloudConfigured);

  runApp(const MeuInventarioApp());
}

class MeuInventarioApp extends StatelessWidget {
  const MeuInventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu InventÃ¡rio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246B5A)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F6),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
