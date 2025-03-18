import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:createtrial/pages/navigatehiker.dart';

/// A model representing an emergency alert from a hiker
/// Contains all relevant information about the emergency
class EmergencyAlert {
  final String id;
  final String hikerName;
  final String trail;
  final String phone;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status; // "Awaiting", "In Progress", "Resolved"

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
      hikerName: map['hikername'],
      trail: map['trail'],
      phone: map['phone'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
      status: map['status'],
    );
  }
}

/// Main dashboard for emergency responders
/// Displays active emergencies and allows responders to accept them
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

  /// Fetches emergency alerts from the backend
  Future<void> _fetchEmergencyAlerts() async {
    setState(() => isLoading = true);
    final response = await supabase.from('sos_requests').select();
    setState(() {
      emergencyAlerts =
          response.map((data) => EmergencyAlert.fromMap(data)).toList();
      isLoading = false;
    });
  }

  /// Called when a responder accepts an emergency
  /// Updates the status and sends acceptance to backend
  Future<void> _acceptEmergency(String alertId) async {
    setState(() => isLoading = true);
    await supabase
        .from('sos_requests')
        .update({'status': 'In Progress'}).eq('id', alertId);
    _fetchEmergencyAlerts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency accepted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final username = args?['username'] ?? 'Responder';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Responder Dashboard'),
        backgroundColor: Colors.redAccent.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEmergencyAlerts,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.redAccent.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Hello, $username',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Active Emergency Alerts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: emergencyAlerts.isEmpty
                      ? const Center(
                          child: Text(
                            'No active emergencies at this time',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: emergencyAlerts.length,
                          itemBuilder: (context, index) {
                            final alert = emergencyAlerts[index];
                            return EmergencyAlertCard(
                              alert: alert,
                              onAccept: () => _acceptEmergency(alert.id),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

/// Widget to display individual emergency alerts
/// Shows hiker information, location data, and provides action buttons
class EmergencyAlertCard extends StatelessWidget {
  final EmergencyAlert alert;
  final VoidCallback onAccept;

  const EmergencyAlertCard({
    super.key,
    required this.alert,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(alert.timestamp);
    final isAwaitingResponse = alert.status == "Awaiting";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isAwaitingResponse ? Colors.red.shade200 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isAwaitingResponse
                  ? Colors.red.shade50
                  : Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sos,
                      color: isAwaitingResponse ? Colors.red : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAwaitingResponse ? 'SOS Emergency' : 'In Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAwaitingResponse ? Colors.red : Colors.orange,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Hiker:', alert.hikerName),
                const SizedBox(height: 8),
                _buildInfoRow('Trail:', alert.trail),
                const SizedBox(height: 8),
                _buildInfoRow('Phone:', alert.phone, isPhone: true),
                const SizedBox(height: 12),
                const Text(
                  "Hiker's Current Location:",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCoordinateRow(
                          'Latitude:', alert.latitude.toString()),
                      const SizedBox(height: 4),
                      _buildCoordinateRow(
                          'Longitude:', alert.longitude.toString()),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.update,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Last updated: ${_formatTime(alert.timestamp)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: ${alert.status}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isAwaitingResponse ? Colors.red : Colors.orange,
                      ),
                    ),
                    if (isAwaitingResponse)
                      ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept Emergency'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Navigate to Hiker'),
                        content: Text(
                          'This would open navigation to coordinates:\n${alert.latitude}, ${alert.longitude}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NavigateHikerPage(
                                    latitude: alert
                                        .latitude, // Pass the latitude from the alert
                                    longitude: alert.longitude,
                                  ),
                                ),
                              );
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate to hiker'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPhone = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isPhone ? Colors.blue : Colors.black87,
            fontWeight: isPhone ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        if (isPhone)
          IconButton(
            icon: const Icon(Icons.phone, size: 18, color: Colors.blue),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // Phone call functionality would go here
            },
          ),
      ],
    );
  }

  Widget _buildCoordinateRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes == 1) {
      return '1 minute ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      return '1 hour ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    final seconds = time.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
