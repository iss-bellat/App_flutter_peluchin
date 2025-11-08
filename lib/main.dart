import 'package:flutter/material.dart';
import 'loading_page.dart';
import 'package:easy_localization/easy_localization.dart'; // Importa la librería

// main() ahora debe ser 'async'
Future<void> main() async {
  // Asegura que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  // Asegura que EasyLocalization esté inicializado
  await EasyLocalization.ensureInitialized();

  // Ejecuta la app, pero envuelta en el widget de EasyLocalization
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('es'), 
        Locale('en')
      ],
      path: 'assets/translations', // La carpeta donde están los JSON
      fallbackLocale: const Locale('es'), // Idioma por si falla
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de RFID',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
            .copyWith(surface: Colors.white),
      ),
      debugShowCheckedModeBanner: false,
      
      // La librería maneja esto automáticamente ahora:
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      home: const LoadingPage(),
    );
  }
}