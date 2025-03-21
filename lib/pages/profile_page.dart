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
                  child: Container(
                    height: 300, // Placeholder for profile header
                    color: Color(0xFF121212),
                    child: Center(
                      child: Text('Profile Header',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
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
}
