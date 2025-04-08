import 'package:createtrial/screens/trail_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'saved_trails_page.dart';
import 'package:createtrial/pages/annotate_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:createtrial/pages/search_page.dart';
import 'blog_list_page.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> trails = [];
  List<Map<String, dynamic>> recommendedTrails = [];
  gl.Position? currentPosition; // Variable to store the user's current location
  String userExperienceLevel = 'Beginner';
  bool _isLoadingUserExperience = true;

  final Map<String, String> experienceToDifficulty = {
    'Beginner': 'Easy',
    'Intermediate': 'Moderate',
    'Expert': 'Hard'
  };

  @override
  void initState() {
    super.initState();
    _fetchUserExperience();
    _fetchTrails();
    _getUserLocation(); // Fetch the user's location when the page loads
  }

  //Function to fetch the user's experience
  Future<void> _fetchUserExperience() async {
    try {
      // 1. Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        setState(() {
          userExperienceLevel = 'Beginner';
          _isLoadingUserExperience = false;
        });
        return;
      }

      // 2. Fetch experience level from Supabase users table
      final response = await Supabase.instance.client
          .from('users')
          .select('hiking_experience')
          .eq('id', userId)
          .single();

      setState(() {
        userExperienceLevel = response['hiking_experience'] ?? 'Beginner';
        _isLoadingUserExperience = false;
      });
    } catch (e) {
      debugPrint('Error fetching user experience: $e');
      setState(() {
        userExperienceLevel = 'Beginner';
        _isLoadingUserExperience = false;
      });
    }
  }

  // Function to fetch the user's current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    gl.LocationPermission permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        debugPrint('Location permission is denied');
        return;
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      debugPrint('Location permission is permanently denied');
      return;
    }

    // Fetch the current position once
    final position = await gl.Geolocator.getCurrentPosition();
    setState(() {
      currentPosition = position;
    });
  }

  Future<void> _fetchTrails() async {
    try {
      final response =
          await http.get(Uri.parse('http://13.53.173.93:5000/api/v1/trails'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final allTrails = data
            .map((trail) => {
                  'id': trail['id'],
                  'name': trail['name'],
                  'description': trail['description'],
                  'image_url': trail['imageUrl'],
                  'difficulty': trail['difficulty_level']?.toString() ?? 'Easy'
                })
            .toList();

        setState(() {
          trails = allTrails;
          _filterRecommendedTrails();
        });
      } else {
        debugPrint('Failed to load trails: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching trails: $e');
    }
  }

  void _filterRecommendedTrails() {
    final targetDifficulty =
        experienceToDifficulty[userExperienceLevel] ?? 'Easy';
    setState(() {
      recommendedTrails = trails.where((trail) {
        return (trail['difficulty'] as String).toLowerCase() ==
            targetDifficulty.toLowerCase();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Welcome to Trailblaze',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SectionTitle(title: 'Available Trails'),
            const SizedBox(height: 10),
            SectionScroll(
              items: trails
                  .map((trail) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrailOverviewScreen(
                                trailId: trail['id'], // Pass the trail ID
                              ),
                            ),
                          );
                        },
                        child: TrailCard(
                          image:
                              trail['image_url'] ?? 'assets/images/trail1.jpg',
                          title: trail['name'] ?? 'Unnamed Trail',
                          subtitle: trail['description'] ??
                              'No description available',
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            SectionTitle(
              title: 'Recommended For $userExperienceLevel',
            ),
            const SizedBox(height: 10),
            SectionScroll(
              items: recommendedTrails
                  .map((trail) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrailOverviewScreen(
                                trailId: trail['id'], // Pass the trail ID
                              ),
                            ),
                          );
                        },
                        child: TrailCard(
                          image:
                              trail['image_url'] ?? 'assets/images/trail1.jpg',
                          title: trail['name'] ?? 'Unnamed Trail',
                          subtitle: trail['description'] ??
                              'No description available',
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Real-Time Trail Conditions'),
            const SizedBox(height: 10),
            WeatherConditionCard(userLocation: currentPosition),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[900],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionTitle(title: 'Trail Blog'),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BlogsListPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Read More',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Best Spring Trails',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Discover the most beautiful trails to explore this spring season with our expert guide.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'By Trail Guide',
                              style: TextStyle(
                                color: Colors.green.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnnotatePage(),
              ),
            );
          },
          elevation: 0,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 56,
        padding: EdgeInsets.zero,
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: Colors.white,
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search),
              color: Colors.grey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(),
                  ),
                );
              },
            ),
            const SizedBox(width: 48), // Space for the FAB
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              color: Colors.grey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedTrailsPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              color: Colors.grey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class SectionScroll extends StatelessWidget {
  final List<Widget> items;

  const SectionScroll({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        children: items,
      ),
    );
  }
}

class TrailCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const TrailCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint('Error loading image: $image');
          },
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherConditionCard extends StatefulWidget {
  final gl.Position? userLocation;

  const WeatherConditionCard({
    super.key,
    required this.userLocation,
  });

  @override
  State<WeatherConditionCard> createState() => _WeatherConditionCardState();
}

class _WeatherConditionCardState extends State<WeatherConditionCard> {
  bool _isLoading = true;
  Map<String, dynamic>? _weatherData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  @override
  void didUpdateWidget(WeatherConditionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fetch weather data again if location changes
    if (widget.userLocation != oldWidget.userLocation) {
      _fetchWeatherData();
    }
  }

  Future<void> _fetchWeatherData() async {
    if (widget.userLocation == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Location not available';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final apiKey = '0081735a90a41deb521051214b0c37e2';
      final lat = widget.userLocation!.latitude;
      final lon = widget.userLocation!.longitude;

      // Using metric units for Celsius
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load weather data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching weather: $e';
      });
      debugPrint('Weather API error: $e');
    }
  }

  // Helper method to get weather icon
  IconData _getWeatherIcon(String? iconCode) {
    if (iconCode == null) return Icons.cloud;

    // Map OpenWeatherMap icon codes to Flutter icons
    switch (iconCode.substring(0, 2)) {
      case '01': // clear sky
        return Icons.wb_sunny;
      case '02': // few clouds
        return Icons.wb_cloudy;
      case '03': // scattered clouds
      case '04': // broken clouds
        return Icons.cloud;
      case '09': // shower rain
        return Icons.grain;
      case '10': // rain
        return Icons.beach_access;
      case '11': // thunderstorm
        return Icons.flash_on;
      case '13': // snow
        return Icons.ac_unit;
      case '50': // mist
        return Icons.blur_on;
      default:
        return Icons.cloud;
    }
  }

  // Helper method to get weather color
  Color _getWeatherColor(String? iconCode) {
    if (iconCode == null) return Colors.grey;

    switch (iconCode.substring(0, 2)) {
      case '01': // clear sky
        return Colors.amber;
      case '02': // few clouds
        return Colors.amber.shade300;
      case '03': // scattered clouds
      case '04': // broken clouds
        return Colors.grey;
      case '09': // shower rain
      case '10': // rain
        return Colors.blue;
      case '11': // thunderstorm
        return Colors.deepPurple;
      case '13': // snow
        return Colors.lightBlueAccent;
      case '50': // mist
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[900],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Weather',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_weatherData != null)
                Text(
                  '${_weatherData!['name']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 3,
                ),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.grey, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Weather data unavailable',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                Icon(
                  _getWeatherIcon(_weatherData?['weather'][0]['icon']),
                  color: _getWeatherColor(_weatherData?['weather'][0]['icon']),
                  size: 42,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_weatherData!['main']['temp'].round()}°C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_weatherData!['weather'][0]['main']}, ${_weatherData!['weather'][0]['description']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wind: ${_weatherData!['wind']['speed']} m/s | Humidity: ${_weatherData!['main']['humidity']}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
