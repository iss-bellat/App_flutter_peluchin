import 'dart:async'; // Necesario para el temporizador
import 'package:flutter/material.dart';
import 'home_page.dart'; // Importa la página a la que quieres ir

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
    // Llama a la función que inicia la carga
    _startLoading();
  }

  // Esta función simula un tiempo de carga
  Future<void> _startLoading() async {
    
    // ---
    // Aquí podrías hacer trabajo real, como pedir permisos,
    // cargar datos desde internet, etc.
    // ---
    
    // Simulamos una espera de 3 segundos
    await Future.delayed(const Duration(seconds: 3));

    // Cuando la carga termina, navega a la HomePage
    // Usamos 'pushReplacement' para que el usuario no pueda
    // presionar "atrás" y volver a la pantalla de carga.
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Un diseño simple para la pantalla de carga
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Puedes poner el color de tu app
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ 
            Image.asset(
              'assets/plche.png', // Tu logo
              width: 150, 
            ),
            const SizedBox(height: 30),
            Padding(
              // Añadimos espacio a los lados para que la barra no sea tan ancha
              padding: const EdgeInsets.symmetric(horizontal: 60.0), 
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.white.withOpacity(0.5), // Un fondo sutil
                minHeight: 6.0, // La hacemos un poco más gruesa
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Iniciando Peluchin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}