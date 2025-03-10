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
}

class ResponderHomePage extends StatefulWidget {
  const ResponderHomePage({super.key});

  @override
  State<ResponderHomePage> createState() => _ResponderHomePageState();
}

class _ResponderHomePageState extends State<ResponderHomePage> {
  List<EmergencyAlert> emergencyAlerts = [];
  bool isLoading = true;
  
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final username = args?['username'] ?? 'Responder';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Responder Dashboard'),
        backgroundColor: Colors.redAccent.shade700,
        foregroundColor: Colors.white,
        actions: [
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
                  child: Center(
                    child: Text(
                      'No alerts loaded yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

@override
void initState() {
  super.initState();
  // Simulate fetching alerts from backend
  _fetchEmergencyAlerts();
}

Future<void> _fetchEmergencyAlerts() async {
  // Simulating API call with a delay
  await Future.delayed(const Duration(seconds: 1));
  
  // Mock data - would be replaced with actual API call
  setState(() {
    emergencyAlerts = [
      EmergencyAlert(
        id: "EM-001",
        hikerName: "John Smith",
        trail: "Mountain Ridge Trail",
        phone: "(555) 123-4567",
        latitude: 37.865100,
        longitude: -119.538300,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        status: "Awaiting",
      ),
      EmergencyAlert(
        id: "EM-002",
        hikerName: "Maria Garcia",
        trail: "Eagle Peak Trail",
        phone: "(555) 987-6543",
        latitude: 37.853200,
        longitude: -119.522100,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        status: "Awaiting",
      ),
    ];
    isLoading = false;
  });
}

// Add refresh button to app bar
actions: [
  IconButton(
    icon: const Icon(Icons.refresh),
    onPressed: () {
      setState(() {
        isLoading = true;
      });
      _fetchEmergencyAlerts();
    },
  ),
  IconButton(
    icon: const Icon(Icons.logout),
    onPressed: () {
      Navigator.pushReplacementNamed(context, '/login');
    },
  ),
],
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
          color: isAwaitingResponse ? Colors.red.shade200 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isAwaitingResponse ? Colors.red.shade50 : Colors.orange.shade50,
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
                _buildInfoRow('Phone:', alert.phone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
}

// Update the ListView in the main class
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
// Add to EmergencyAlertCard widget's build method, inside the Column
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
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildCoordinateRow('Latitude:', alert.latitude.toString()),
      const SizedBox(height: 4),
      _buildCoordinateRow('Longitude:', alert.longitude.toString()),
      const SizedBox(height: 4),
      Row(
        children: [
          const Icon(Icons.update, size: 16, color: Colors.grey),
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

// Add these methods to EmergencyAlertCard class
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

String _formatTime(DateTime time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  final seconds = time.second.toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

// Add to ResponderHomePage class
Future<void> _acceptEmergency(String alertId) async {
  // Show loading indicator
  setState(() {
    isLoading = true;
  });
  
  // Simulate API call to accept the emergency
  await Future.delayed(const Duration(seconds: 1));
  
  // Update local state after successful API call
  setState(() {
    final index = emergencyAlerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      final updatedAlerts = List<EmergencyAlert>.from(emergencyAlerts);
      final currentAlert = updatedAlerts[index];
      
      // Create a new alert with updated status
      updatedAlerts[index] = EmergencyAlert(
        id: currentAlert.id,
        hikerName: currentAlert.hikerName,
        trail: currentAlert.trail,
        phone: currentAlert.phone,
        latitude: currentAlert.latitude,
        longitude: currentAlert.longitude,
        timestamp: currentAlert.timestamp,
        status: "In Progress",
      );
      
      emergencyAlerts = updatedAlerts;
    }
    isLoading = false;
  });
  
  // Show confirmation
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Emergency accepted successfully'),
      backgroundColor: Colors.green,
    ),
  );
}

// Add to EmergencyAlertCard, after location display
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

// Add to EmergencyAlertCard, after the status row
const SizedBox(height: 12),
OutlinedButton.icon(
  onPressed: () {
    // This would navigate to a map view or external map app
    // For now, just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigate to Hiker'),
        content: Text(
          'This would open navigation to coordinates:\n${alert.latitude}, ${alert.longitude}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
// Update Card border radius and shadow
Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: isAwaitingResponse ? Colors.red.shade200 : Colors.orange.shade200,
      width: 1,
    ),
  ),
  elevation: 2,
  // ...
)

// Update fonts and colors for better contrast
Text(
  isAwaitingResponse ? 'SOS Emergency' : 'In Progress',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: isAwaitingResponse ? Colors.red : Colors.orange,
    fontSize: 15,
  ),
),

// Improve coordinate display layout
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
        offset: Offset(0, 1),
      ),
    ],
  ),
  // ...
)
// Update _buildInfoRow in EmergencyAlertCard to add phone integration
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

// Update phone row in build method
_buildInfoRow('Phone:', alert.phone, isPhone: true),

// Add documentation comments at the top of each class
/// A model representing an emergency alert from a hiker
/// Contains all relevant information about the emergency
class EmergencyAlert {
  // ...
}

/// Main dashboard for emergency responders
/// Displays active emergencies and allows responders to accept them
class ResponderHomePage extends StatefulWidget {
  // ...
}

/// Widget to display individual emergency alerts
/// Shows hiker information, location data, and provides action buttons
class EmergencyAlertCard extends StatelessWidget {
  // ...
}

// Add comments before key methods
/// Fetches emergency alerts from the backend
/// Will be replaced with actual API call implementation
Future<void> _fetchEmergencyAlerts() async {
  // ...
}

/// Called when a responder accepts an emergency
/// Updates the status and sends acceptance to backend
Future<void> _acceptEmergency(String alertId) async {
  // ...
}

// Organize imports
import 'package:flutter/material.dart';
// Add any other imports that would be needed