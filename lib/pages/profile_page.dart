import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  static const String routeName = '/profile';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showStickyTabs = false;
  Map<String, dynamic>? _userDetails;
  List<Map<String, dynamic>> _userTrails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);
    _fetchUserDetails();
  }

  void _scrollListener() {
    const stickyThreshold = 300.0;

    if (_scrollController.offset > stickyThreshold && !_showStickyTabs) {
      setState(() {
        _showStickyTabs = true;
      });
    } else if (_scrollController.offset <= stickyThreshold && _showStickyTabs) {
      setState(() {
        _showStickyTabs = false;
      });
    }
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      // Fetch user details
      final userResponse = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      // Fetch trails created by the user
      final trailsResponse = await Supabase.instance.client
          .from('trails')
          .select('id, name, distance_meters, duration_seconds')
          .eq('user_id', userId);

      setState(() {
        _userDetails = userResponse;
        _userTrails = trailsResponse;
        _isLoading = false;
      });
    }
  }

  List<String> _getStaticImageUrls() {
    return [
      'https://example.com/image1.jpg',
      'https://example.com/image2.jpg',
      'https://example.com/image3.jpg',
      'https://example.com/image4.jpg',
      'https://example.com/image5.jpg',
    ];
  }

  String _getImageUrlForTrail(int index) {
    final imageUrls = _getStaticImageUrls();
    return imageUrls[index % imageUrls.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.logout, color: Colors.green),
            label: Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await logout();
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(),
                ),
                SliverToBoxAdapter(
                  child: _buildTabBar(),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildActivityTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
          if (_showStickyTabs)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black,
                child: _buildTabBar(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    try {
      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Call the backend logout endpoint
      final response = await http.post(
        Uri.parse('http://13.53.173.93:5000/api/v1/logout'),
        headers: {
          'Cookie': 'SessionID=${prefs.getString('accessToken')}',
        },
      );

      if (response.statusCode == 200) {
        // Clear the token from SharedPreferences
        await prefs.remove('accessToken');

        // Navigate to the landing page or login page
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/landing',
          (Route<dynamic> route) => false, // Remove all routes
        );
      } else {
        // Handle logout failure
        print('Logout failed: ${response.body}');
      }
    } catch (e) {
      // Handle any errors that occur during the logout process
      print('Logout error: $e');
    }
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.green,
        labelColor: Colors.green,
        unselectedLabelColor: Colors.white,
        tabs: [
          Tab(text: 'Activity'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: Colors.green.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage('assets/images/kanye.jpg'),
                backgroundColor: Colors.green.withOpacity(0.2),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userDetails?['username'] ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _userDetails?['address'] ?? 'Loading...',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Add ellipsis for overflow
                            maxLines: 1, // Limit to one line
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.terrain, '157 mi', 'Distance'),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.green.withOpacity(0.3),
                    ),
                    _buildStatItem(Icons.timer, '42 hrs', 'Time'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.green));
    }

    if (_userTrails.isEmpty) {
      return Center(
        child: Text(
          'No trails found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _userTrails.length,
      itemBuilder: (context, index) {
        final trail = _userTrails[index];
        final imageUrl = _getImageUrlForTrail(index);

        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _buildActivityCard(
            trail['trail_name'],
            'Completed a ${trail['trail_length']} mile hike',
            '${DateTime.now().difference(DateTime.parse(trail['created_at'])).inDays} days ago',
            imageUrl,
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(
      String trailName, String activity, String time, String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Navigate to trail details page
        // Navigator.of(context).pushNamed('/trail-details', arguments: trailName);
      },
      child: Card(
        elevation: 3,
        color: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[800],
                    child: Center(
                      child: Icon(Icons.landscape,
                          size: 50, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trailName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    activity,
                    style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reviews-related code remains unchanged
  Widget _buildReviewsTab() {
    return FutureBuilder(
      future:
          Future.delayed(Duration(milliseconds: 300), () => _getMockReviews()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading reviews',
                  style: TextStyle(color: Colors.white)));
        }

        final reviews = snapshot.data as List<Map<String, dynamic>>;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: _buildReviewCard(
                review['trailName'],
                review['rating'],
                review['review'],
                review['time'],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewCard(
      String trailName, double rating, String review, String time) {
    return Card(
      elevation: 3,
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trailName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to trail details page
                    // Navigator.of(context).pushNamed('/trail-details', arguments: trailName);
                  },
                  child: Icon(Icons.arrow_forward, color: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating.floor()
                        ? Icons.star
                        : (index == rating.floor() && rating % 1 > 0)
                            ? Icons.star_half
                            : Icons.star_border,
                    color: Colors.green,
                    size: 20,
                  );
                }),
                SizedBox(width: 8),
                Text(
                  rating.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              review,
              style: TextStyle(fontSize: 16, color: Colors.grey[300]),
            ),
            SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockReviews() {
    return [
      {
        'trailName': 'Mt. Sanitas Trail',
        'rating': 4.5,
        'review':
            'Great views of Boulder! Pretty steep in some sections but worth it.',
        'time': '2 days ago',
      },
      {
        'trailName': 'Flatirons Vista',
        'rating': 5.0,
        'review':
            'One of my favorite trails around Boulder. Beautiful meadows and mountain views.',
        'time': '1 week ago',
      },
      {
        'trailName': 'Royal Arch Trail',
        'rating': 4.0,
        'review':
            'Challenging trail with a spectacular view at the top. Bring plenty of water.',
        'time': '2 weeks ago',
      },
    ];
  }
}
