import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'data_service.dart'; // Importa el cerebro
import 'package:easy_localization/easy_localization.dart'; // Importa traducciones

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _getPairedDevices();
    dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } on PlatformException {
      print("Error obteniendo dispositivos");
    }
    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    setState(() { _isConnecting = true; });
    bool success = await dataService.connect(device);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Conectado a ${device.name}' : 'Error al conectar'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
    if (!mounted) return;
    setState(() { _isConnecting = false; });
  }

  // (Quitamos _showLanguageDialog porque ahora es una pestaña separada)

  @override
  Widget build(BuildContext context) {
    // ESTE CÓDIGO YA NO ES NECESARIO (se borró)
    // super.build(context); 

    return SingleChildScrollView(
      // Padding en la parte de abajo para la barra flotante
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), 
      child: Column(
        children: [
          
          DropdownButtonFormField<BluetoothDevice>(
            items: _devices.map((device) => DropdownMenuItem(
              value: device,
              child: Text(device.name ?? device.address),
            )).toList(),
            onChanged: (device) {
              setState(() {
                _selectedDevice = device;
              });
            },
            decoration: InputDecoration(
              labelText: 'paired_devices'.tr(), 
              border: const OutlineInputBorder(),
            ),
            hint: Text('select_device'.tr()), 
          ),
          const SizedBox(height: 20),
          
          if (_isConnecting)
            const CircularProgressIndicator()
          else if (!dataService.isConnected)
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: _selectedDevice == null ? null : () {
                _connectToDevice(_selectedDevice!);
              },
              child: Text('connect_button'.tr()), 
            )
          else
            Card(
              color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column( 
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          'connected_status'.tr(), 
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), 
                    ElevatedButton(
                      onPressed: () {
                        dataService.disconnect();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, 
                        foregroundColor: Colors.red.shade700, 
                      ),
                      child: Text('disconnect_button'.tr()), 
                    ), 
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}