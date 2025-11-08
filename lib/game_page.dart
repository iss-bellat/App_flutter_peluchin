import 'dart:async';
import 'package:flutter/material.dart';
import 'data_service.dart'; // Importa el cerebro
import 'package:easy_localization/easy_localization.dart'; // Importa traducciones

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  StreamSubscription<String>? _uidSubscription;

  String _expectedValue = ""; 
  String _statusMessage = "game_choose_item"; // Clave de traducción
  Color _backgroundColor = Colors.grey.shade800;
  IconData _displayIcon = Icons.gamepad_outlined;
  bool _waitingForCard = false; 

  List<Map<String, String>> _gameItems = [];

  @override
  void initState() {
    super.initState();
    _uidSubscription = dataService.uidStream.listen(_onUidReceived);
    dataService.addListener(_onDataChanged);
    _loadGameItems();
    _onDataChanged(); 
  }

  @override
  void dispose() {
    _uidSubscription?.cancel();
    dataService.removeListener(_onDataChanged);
    super.dispose();
  }
  
  void _loadGameItems() {
    _gameItems = dataService.getAllGameItems();
  }
  
  void _onDataChanged() {
    if (mounted && !_waitingForCard) {
      _resetGame();
    }
  }

  void _onUidReceived(String uid) {
    if (!_waitingForCard) return; 

    final isCorrect = dataService.logGameResult(uid, _expectedValue);
    
    // --- (Llamada de audio BORRADA) ---
    if (isCorrect) {
      // Envía el comando para reproducir "0001.mp3"
      dataService.sendCommand("PLAY:1"); 
    } else {
      // Envía el comando para reproducir "0002.mp3"
      dataService.sendCommand("PLAY:2");
    }

    setState(() {
      _waitingForCard = false; 
      if (isCorrect) {
        _statusMessage = "game_correct"; // Clave de traducción
        _backgroundColor = Colors.green;
        _displayIcon = Icons.check;
      } else {
        _statusMessage = "game_incorrect"; // Clave de traducción
        _backgroundColor = Colors.red;
        _displayIcon = Icons.close;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _resetGame();
      }
    });
  }

  void _onItemTapped(String value) {
    if (!dataService.isConnected) {
      _resetGame("game_no_connection");
      return;
    }
    if (dataService.activeUser == null) {
      _resetGame("game_no_user");
      return;
    }

    setState(() {
      _expectedValue = value;
      _statusMessage = "game_scan_card_of"; // Clave de traducción
      _backgroundColor = Colors.indigo;
      _displayIcon = Icons.nfc;
      _waitingForCard = true; 
    });

    // --- (Llamada de audio BORRADA) ---
    // ¡¡AÑADIMOS LA LÓGICA DE INSTRUCCIONES AQUÍ!!
    // Mapea el valor del botón al número de pista de audio
    String? trackToPlay;
    
    // Usamos los valores de tu base de datos en data_service.dart
    if (value == "VERDE") {
      trackToPlay = "3"; // "Acerca la tarjeta verde" (0003.mp3)
    } else if (value == "ROJO") {
      trackToPlay = "4"; // "Acerca la tarjeta roja" (0004.mp3)
    } else if (value == "AZUL") {
      trackToPlay = "5"; // "Acerca la tarjeta azul" (0005.mp3)
    }
    // (No tenemos audios para ANIMAL o NUMERO, así que no sonarán)

    // Si encontramos una pista de instrucción, la enviamos
    if (trackToPlay != null) {
      dataService.sendCommand("PLAY:$trackToPlay");
    }
  }

  void _resetGame([String? customMessageKey]) {
     String messageKey = customMessageKey ?? "game_choose_item";
    if (dataService.activeUser == null) {
      messageKey = "game_no_user";
    } else if (!dataService.isConnected) {
      messageKey = "game_no_connection";
    }
    
    setState(() {
      _statusMessage = messageKey;
      _backgroundColor = Colors.grey.shade800;
      _displayIcon = Icons.gamepad_outlined;
      _waitingForCard = false;
      _expectedValue = "";
    });
  }

  Color _getColorForCategory(String category) {
    if (category == 'ANIMAL') return Colors.brown.shade100;
    if (category == 'COLOR') return Colors.blue.shade100;
    if (category == 'NUMERO') return Colors.teal.shade100;
    return Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: _backgroundColor,
          width: double.infinity,
          height: 250, 
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_displayIcon, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  _statusMessage.tr(namedArgs: {'value': _expectedValue}),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        
        Expanded(
          child: _waitingForCard
              ? const Center(child: CircularProgressIndicator()) 
              : GridView.builder(
                  // Padding para la barra flotante
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _gameItems.length,
                  itemBuilder: (context, index) {
                    final item = _gameItems[index];
                    final value = item['value']!;
                    final category = item['category']!;
                    
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getColorForCategory(category),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                      ),
                      onPressed: () => _onItemTapped(value),
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }
}