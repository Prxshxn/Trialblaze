import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trail.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.2:5000/api/v1';

  // Fetch a trail by ID
  static Future<Trail> getTrailById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/trails/$id'));

    if (response.statusCode == 200) {
      return Trail.fromJson(jsonDecode(response.body));
    
  }
}
