import 'package:flutter/material.dart';
import 'data_service.dart';
import 'package:easy_localization/easy_localization.dart'; 

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

// ESTA LÍNEA ESTÁ LIMPIA (YA NO TIENE 'with AutomaticKeepAliveClientMixin')
class _StatisticsPageState extends State<StatisticsPage> {
  final TextEditingController _userController = TextEditingController();

  // ESTA LÍNEA NO ES NECESARIA (se borró)
  // @override bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    dataService.removeListener(_onDataChanged);
    _userController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // ESTA LÍNEA YA NO ES NECESARIA (se borró)
    // super.build(context);

    final users = dataService.allUsers;
    final activeUser = dataService.activeUser;
    final stats = dataService.activeUserStats;

    int totalCorrect = 0;
    int totalIncorrect = 0;
    if (stats != null) {
      for (var map in stats.correctCounts.values) {
        for (var count in map.values) { totalCorrect += count; }
      }
      for (var map in stats.incorrectCounts.values) {
        for (var count in map.values) { totalIncorrect += count; }
      }
    }
    int totalScans = totalCorrect + totalIncorrect;
    double percentage = (totalScans == 0) ? 0 : (totalCorrect / totalScans);

    return ListView(
      // Padding en la parte de abajo para la barra flotante
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
      children: [
        TextField(
          controller: _userController,
          decoration: InputDecoration(
            labelText: 'stats_new_user_name'.tr(),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (_userController.text.isNotEmpty) {
              dataService.addUser(_userController.text);
              _userController.clear();
            }
          },
          child: Text('stats_add_user'.tr()),
        ),
        const SizedBox(height: 20),
        if (users.isNotEmpty)
          DropdownButtonFormField<String>(
            value: activeUser,
            hint: Text('stats_select_user'.tr()),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: users.map((String userName) {
              return DropdownMenuItem<String>(
                value: userName,
                child: Text(userName),
              );
            }).toList(),
            onChanged: (String? newValue) {
              dataService.setActiveUser(newValue);
            },
          )
        else
          Text('stats_no_users'.tr()),
        const SizedBox(height: 30),
        if (activeUser != null && stats != null) ...[
          Text('stats_title'.tr(args: [activeUser]), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 15),

          // Tarjeta de Resumen de Porcentaje
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('stats_summary'.tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue.shade900)),
                  const SizedBox(height: 10),
                  Text(
                    '${(percentage * 100).toStringAsFixed(1)}% ${'stats_percent_correct'.tr()}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('${'stats_total_correct'.tr()}: $totalCorrect', style: const TextStyle(fontSize: 16)),
                  Text('${'stats_total_incorrect'.tr()}: $totalIncorrect', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tarjetas de Aciertos
          _buildStatsCard('stats_correct_animals'.tr(), stats.correctCounts['ANIMAL']!),
          _buildStatsCard('stats_correct_colors'.tr(), stats.correctCounts['COLOR']!),
          _buildStatsCard('stats_correct_numbers'.tr(), stats.correctCounts['NUMERO']!),
          const SizedBox(height: 20),
          
          // Tarjetas de Errores
          _buildStatsCard('stats_errors_animals'.tr(), stats.incorrectCounts['ANIMAL']!, isError: true),
          _buildStatsCard('stats_errors_colors'.tr(), stats.incorrectCounts['COLOR']!, isError: true),
          _buildStatsCard('stats_errors_numbers'.tr(), stats.incorrectCounts['NUMERO']!, isError: true),
        ]
        else
          Center(child: Text('stats_select_user'.tr())),
      ],
    );
  }

  Widget _buildStatsCard(String title, Map<String, int> data, {bool isError = false}) {
    Color cardColor = isError ? Colors.red.shade50 : Colors.green.shade50;
    Color titleColor = isError ? Colors.red.shade900 : Colors.green.shade900;
    
    String subtitle = isError ? 'stats_no_errors'.tr() : 'stats_no_attempts'.tr();
    String countText = isError ? 'errores' : 'aciertos'; 

    if (data.isEmpty) {
      return Card(
        color: Colors.white,
        child: ListTile(title: Text(title), subtitle: Text(subtitle)),
      );
    }
    
    int total = 0;
    data.forEach((key, value) {
      total += value;
    });

    final entries = data.entries.map((entry) {
      return Text('  • ${entry.key}: ${entry.value} $countText');
    }).toList();

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: titleColor)),
            Text('${'stats_total'.tr()}: $total $countText', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...entries,
          ],
        ),
      ),
    );
  }
}