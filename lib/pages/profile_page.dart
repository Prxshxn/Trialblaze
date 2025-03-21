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
                // Activity Tab - placeholder
                Center(
                    child: Text('Activity Tab',
                        style: TextStyle(color: Colors.white))),
                // Reviews Tab - placeholder
                Center(
                    child: Text('Reviews Tab',
                        style: TextStyle(color: Colors.white))),
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
        color: Color(0xFF121212), // Dark theme background
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
}
