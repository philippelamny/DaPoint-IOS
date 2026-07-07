import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'data/session_repository.dart';
import 'screens/splash_screen.dart';
import 'theme/brand.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  final repository = SessionRepository(AppDatabase());
  await repository.init();

  runApp(DaPointApp(repository: repository));
}

class DaPointApp extends StatelessWidget {
  const DaPointApp({super.key, required this.repository});

  final SessionRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: repository,
      child: MaterialApp(
        title: 'DaPoint',
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr'),
        theme: Brand.theme(),
        home: const SplashScreen(),
      ),
    );
  }
}
