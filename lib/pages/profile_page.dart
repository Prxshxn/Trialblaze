import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to scroll position to handle sticky tabs
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Adjust this value based on when you want the tabs to become sticky
    // This value should be approximately the height of content above the tabs
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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.logout, color: Colors.green),
            label: Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () {
              // Call your authentication service to log out
              // authService.signOut();
              // Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          SizedBox(width: 8), // Add some padding on the right
        ],
      ),
      body: Stack(
        children: [
          // Main scrollable content
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
                // Activity Tab
                _buildActivityTab(),
                // Reviews Tab
                _buildReviewsTab(),
              ],
            ),
          ),

          // Sticky tabs that appear when scrolling
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
        color: Colors.black, // Dark theme background
        border: Border(
          bottom: BorderSide(
            color: Colors.green.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Profile Picture and Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture - Made bigger
              CircleAvatar(
                radius: 55, // Increased from 40
                backgroundImage:
                    AssetImage('assets/images/profile_default.jpg'),
                // Use NetworkImage for remote images if user has set one
                // backgroundImage: NetworkImage(user.profileUrl),
                backgroundColor: Colors.green.withOpacity(0.2),
              ),
              SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Hiker', // Replace with user.displayName
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
                        Text(
                          'Boulder, Colorado', // Replace with user.location
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
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
          // Stats Card
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E), // Dark card background
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.green.withOpacity(0.5), width: 1),
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
    return FutureBuilder(
      // Replace with your actual data fetching function
      // future: userActivityService.getUserActivities(userId),
      future: Future.delayed(
          Duration(milliseconds: 300), () => _getMockActivities()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading activities',
                  style: TextStyle(color: Colors.white)));
        }

        final activities = snapshot.data as List<Map<String, dynamic>>;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: _buildActivityCard(
                activity['trailName'],
                activity['description'],
                activity['time'],
                activity['imageUrl'],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return FutureBuilder(
      // Replace with your actual data fetching function
      // future: reviewService.getUserReviews(userId),
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
              child: Image.asset(
                'assets/images/trails/$imageUrl', // Use your asset path format
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[800],
                    child: Center(
                        child: Icon(Icons.landscape,
                            size: 50, color: Colors.grey[600])),
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

  // Mock data methods - replace with your actual data services
  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        'trailName': 'Mt. Sanitas Trail',
        'description': 'Completed a 3.2 mile hike',
        'time': '2 days ago',
        'imageUrl': 'mt_sanitas.jpg',
      },
      {
        'trailName': 'Flatirons Vista',
        'description': 'Completed a 5.8 mile hike',
        'time': '1 week ago',
        'imageUrl': 'flatirons_vista.jpg',
      },
      {
        'trailName': 'Royal Arch Trail',
        'description': 'Completed a 3.5 mile hike',
        'time': '2 weeks ago',
        'imageUrl': 'royal_arch.jpg',
      },
    ];
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
