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