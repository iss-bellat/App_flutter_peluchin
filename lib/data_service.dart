import 'dart:async';
import 'dart:convert';
import 'dart:typed_data'; // Para Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// --- Clases de Estadísticas y Cerebro ---
class UserStats {
  final Map<String, Map<String, int>> correctCounts = {
    'ANIMAL': {}, 'COLOR': {}, 'NUMERO': {},
  };
  final Map<String, Map<String, int>> incorrectCounts = {
    'ANIMAL': {}, 'COLOR': {}, 'NUMERO': {},
  };
}

class DataService with ChangeNotifier {
  BluetoothConnection? _connection;
  bool isConnected = false;
  String _messageBuffer = "";
  final _uidStreamController = StreamController<String>.broadcast();
  Stream<String> get uidStream => _uidStreamController.stream;

  final Map<String, UserStats> _userData = {};
  String? _activeUser;

  // --- Base de Datos del Juego ---
  // (Asegúrate de que estos UIDs sean los correctos)
  final Map<String, Map<String, String>> cardDatabase = {
    "04 93 1A 63": {"ANIMAL": "PERRO", "COLOR": "ROJO", "NUMERO": "UNO"},
    "E3 B5 45 1C": {"ANIMAL": "GATO", "COLOR": "AZUL", "NUMERO": "DOS"},
    "13 11 11 36": {"ANIMAL": "OSO", "COLOR": "VERDE", "NUMERO": "TRES"},
    // ... añade más tarjetas si las tienes
  };
  
  // --- (SECCIÓN DE AUDIO BORRADA) ---
Future<void> sendCommand(String command) async {
    // Solo envía si estamos conectados
    if (_connection != null && _connection!.isConnected) {
      try {
        // Añadimos un salto de línea '\n' para que Arduino
        // sepa cuándo termina el comando.
        String commandWithNewline = "$command\n"; 
        
        // Convierte el string a bytes (Uint8List) y lo envía
        _connection!.output.add(Uint8List.fromList(utf8.encode(commandWithNewline)));
        await _connection!.output.allSent;
        print('Comando enviado a Arduino: $command');
      } catch (e) {
        print('Error al enviar comando: $e');
      }
    } else {
      print('No se puede enviar comando: Bluetooth no conectado.');
    }
  }
  // --- Métodos de Usuarios ---
  String? get activeUser => _activeUser;
  List<String> get allUsers => _userData.keys.toList();
  UserStats? get activeUserStats => _userData[_activeUser];

  void addUser(String name) {
    if (name.isNotEmpty && !_userData.containsKey(name)) {
      _userData[name] = UserStats();
      notifyListeners();
    }
  }

  void setActiveUser(String? userName) {
    if (_userData.containsKey(userName)) {
      _activeUser = userName;
      notifyListeners();
    }
  }

  // --- Métodos del Juego ---
  List<Map<String, String>> getAllGameItems() {
    final List<Map<String, String>> items = [];
    cardDatabase.forEach((uid, data) {
      data.forEach((category, value) {
        if (!items.any((item) => item['value'] == value)) {
          items.add({'category': category, 'value': value});
        }
      });
    });
    items.sort((a, b) => a['value']!.compareTo(b['value']!));
    return items;
  }
  String? _getUidForValue(String val) {
    for (var e in cardDatabase.entries) { if (e.value.containsValue(val)) return e.key; } return null;
  }
  String? _getCategoryForValue(String val) {
    for (var d in cardDatabase.values) { for (var e in d.entries) { if (e.value == val) return e.key; } } return null;
  }
  bool logGameResult(String scannedUid, String expectedValue) {
    if (_activeUser == null) return false;
    final stats = _userData[_activeUser]!;
    final expectedUid = _getUidForValue(expectedValue);
    final category = _getCategoryForValue(expectedValue);
    if (category == null) return false;
    bool isCorrect = (scannedUid == expectedUid);
    if (isCorrect) {
      stats.correctCounts[category]![expectedValue] = (stats.correctCounts[category]![expectedValue] ?? 0) + 1;
    } else {
      stats.incorrectCounts[category]![expectedValue] = (stats.incorrectCounts[category]![expectedValue] ?? 0) + 1;
    }
    notifyListeners();
    return isCorrect;
  }

  // --- Métodos de Conexión Bluetooth ---
  
  // --- (Función sendCommand BORRADA) ---
  
  Future<bool> connect(BluetoothDevice device) async {
    try {
      if (_connection != null && _connection!.isConnected) { await _connection!.close(); }
      _connection = await BluetoothConnection.toAddress(device.address);
      isConnected = true;
      notifyListeners();

      // Lógica de escucha (parser) robusta
      _connection!.input!.listen((Uint8List data) {
        try {
          _messageBuffer += ascii.decode(data);
          while (_messageBuffer.contains('\n')) {
            int newlineIndex = _messageBuffer.indexOf('\n');
            String completeMessage = _messageBuffer.substring(0, newlineIndex).trim();
            _messageBuffer = _messageBuffer.substring(newlineIndex + 1);

            if (completeMessage.toUpperCase().contains("UID:")) {
               String uid = completeMessage.substring(completeMessage.indexOf(':') + 1).trim(); 
               if (uid.isNotEmpty) {
                  _uidStreamController.add(uid); 
               }
            }
          }
        } catch (e) {
          print('Error parseando datos BT: $e');
          _messageBuffer = ""; 
        }
      }).onDone(() {
        isConnected = false;
        notifyListeners();
      });
      return true;
    } catch (e) {
      print('Error al conectar: $e');
      isConnected = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connection != null && _connection!.isConnected) {
      await _connection!.close();
    }
    isConnected = false;
    notifyListeners();
  }
}

// Objeto Global
final DataService dataService = DataService();