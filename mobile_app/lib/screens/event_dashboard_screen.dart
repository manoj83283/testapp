import 'package:flutter/material.dart';
import '../models/event_service_model.dart';
import '../services/api_service.dart';

class EventDashboardScreen extends StatefulWidget {
  final String token;
  const EventDashboardScreen({required this.token, super.key});

  @override
  State<EventDashboardScreen> createState() => _EventDashboardScreenState();
}

class _EventDashboardScreenState extends State<EventDashboardScreen> {
  late Future<List<EventServiceModel>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = ApiService().fetchEventServices(widget.token);
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'camera_alt':
        return Icons.camera_alt;
      case 'brush':
        return Icons.brush;
      case 'celebration':
        return Icons.celebration;
      case 'music_note':
        return Icons.music_note;
      case 'mic':
        return Icons.mic;
      case 'spa':
        return Icons.spa;
      case 'headphones':
        return Icons.headphones;
      case 'event':
        return Icons.event;
      case 'child_care':
        return Icons.child_care;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_dining':
        return Icons.local_dining;
      case 'emoji_emotions':
        return Icons.emoji_emotions;
      case 'palette':
        return Icons.palette;
      case 'groups':
        return Icons.groups;
      default:
        return Icons.miscellaneous_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Dashboard')),
      body: FutureBuilder<List<EventServiceModel>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No event services available'));
          }

          final services = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to detail screen later
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getIcon(service.icon), size: 50, color: Colors.pink),
                      const SizedBox(height: 10),
                      Text(service.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}