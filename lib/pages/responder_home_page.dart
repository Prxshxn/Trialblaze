import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyAlert {
  final String id;
  final String hikerName;
  final String trail;
  final String phone;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status;

  EmergencyAlert({
    required this.id,
    required this.hikerName,
    required this.trail,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
  });

  factory EmergencyAlert.fromMap(Map<String, dynamic> map) {
    return EmergencyAlert(
      id: map['id'],
      hikerName: map['hiker_name'],
      trail: map['trail'],
      phone: map['phone'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
      status: map['status'],
    );
  }
}

class ResponderHomePage extends StatefulWidget {
  const ResponderHomePage({super.key});

  @override
  State<ResponderHomePage> createState() => _ResponderHomePageState();
}

class _ResponderHomePageState extends State<ResponderHomePage> {
  final supabase = Supabase.instance.client;
  List<EmergencyAlert> emergencyAlerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmergencyAlerts();
  }

  Future<void> _fetchEmergencyAlerts() async {
    setState(() => isLoading = true);
    final response = await supabase.from('sos_requests').select();
    setState(() {
      emergencyAlerts =
          response.map((data) => EmergencyAlert.fromMap(data)).toList();
      isLoading = false;
    });
  }

  Future<void> _acceptEmergency(String alertId) async {
    setState(() => isLoading = true);
    await supabase
        .from('emergency_alerts')
        .update({'status': 'In Progress'}).eq('id', alertId);
    _fetchEmergencyAlerts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Emergency accepted successfully'),
          backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Responder Dashboard'),
        backgroundColor: Colors.redAccent.shade700,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchEmergencyAlerts),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: emergencyAlerts.length,
              itemBuilder: (context, index) {
                final alert = emergencyAlerts[index];
                return ListTile(
                  title: Text(alert.hikerName),
                  subtitle: Text('Trail: ${alert.trail}'),
                  trailing: alert.status == "Awaiting"
                      ? ElevatedButton(
                          onPressed: () => _acceptEmergency(alert.id),
                          child: const Text("Accept"))
                      : Text(alert.status),
                );
              },
            ),
    );
  }
}
