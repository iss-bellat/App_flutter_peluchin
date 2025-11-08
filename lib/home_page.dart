import 'package:flutter/material.dart';
import 'bluetooth_page.dart';
import 'statistics_page.dart'; 
import 'game_page.dart';
import 'language_page.dart'; // <-- Importa la 4ta pestaña
import 'data_service.dart';   // Importa el cerebro
import 'package:easy_localization/easy_localization.dart'; // Importa traducciones

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indiceSeleccionado = 0;
  bool _isBluetoothConnected = false;

  // La lista de pantallas que se mostrarán
  final List<Widget> _pantallas = [
    const BluetoothPage(),
    const GamePage(),
    const StatisticsPage(),
    const LanguagePage(), // <-- Añade la 4ta pestaña
  ];

  @override
  void initState() {
    super.initState();
     // Escucha los "avisos" del cerebro
    dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    dataService.removeListener(_onDataChanged);
    super.dispose();
  }
  
  // Esta función se llama si el cerebro avisa de un cambio
  void _onDataChanged() {
    // Revisa si el estado de conexión cambió
    if (mounted && _isBluetoothConnected != dataService.isConnected) {
      setState(() {
        _isBluetoothConnected = dataService.isConnected;
      });
    }
  }

  void _alTocarPestana(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          // --- CAPA 1: EL CONTENIDO ---
          
          // Envuelve el contenido en un SafeArea
          // Esto empuja todo hacia abajo de la barra de estado (hora, batería)
          SafeArea(
            bottom: false, // No queremos SafeArea en la parte de abajo
            child: IndexedStack(
              index: _indiceSeleccionado,
              children: _pantallas,
            ),
          ),

          // --- CAPA 2: LA BARRA DE NAVEGACIÓN FLOTANTE ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0), 
              child: Container(
                decoration: BoxDecoration(
                  // Usamos el color 'surface' del tema
                  color: Theme.of(context).colorScheme.surface, 
                  borderRadius: BorderRadius.circular(50), 
                  boxShadow: [ 
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed, // Mantiene los iconos fijos
                    selectedFontSize: 12.0,
                    unselectedFontSize: 12.0,
                    backgroundColor: Colors.transparent, // Fondo transparente
                    elevation: 0, // Sin sombra (el Container ya la tiene)
                    currentIndex: _indiceSeleccionado,
                    onTap: _alTocarPestana,
                    selectedItemColor: Colors.blueAccent, // Color del ítem activo
                    unselectedItemColor: Colors.grey.shade600, // Color de ítems inactivos

                    // --- ¡TEXTOS TRADUCIDOS! ---
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(_isBluetoothConnected ? Icons.bluetooth_connected : Icons.bluetooth, size: 22),
                        label: 'tab_connect'.tr(), // <-- Pestaña 1
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.gamepad_outlined, size: 22),
                        label: 'tab_game'.tr(), // <-- Pestaña 2
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.bar_chart, size: 22),
                        label: 'tab_stats'.tr(), // <-- Pestaña 3
                      ),
                      BottomNavigationBarItem( // <-- Pestaña 4
                        icon: const Icon(Icons.language, size: 22),
                        label: 'tab_language'.tr(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}