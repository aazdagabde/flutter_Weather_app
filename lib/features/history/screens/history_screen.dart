import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (userId != null) {
        Provider.of<HistoryProvider>(context, listen: false)
            .fetchHistory(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Historique"),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (historyProvider.historyEntries.isEmpty) {
            return const Center(child: Text("Votre historique est vide."));
          }

          return ListView.builder(
            itemCount: historyProvider.historyEntries.length,
            itemBuilder: (context, index) {
              final entry = historyProvider.historyEntries[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(entry.cityName),
                subtitle: Text(
                  // Formate la date pour être plus lisible
                  DateFormat('le dd/MM/yyyy à HH:mm')
                      .format(entry.consultationDate),
                ),
                trailing: Text(
                  "${entry.temperature.toStringAsFixed(1)}°C",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
