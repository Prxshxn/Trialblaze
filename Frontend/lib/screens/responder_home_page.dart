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