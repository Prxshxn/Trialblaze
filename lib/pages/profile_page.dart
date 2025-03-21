import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = '/profile';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Activity Tab - placeholder
          Center(
              child:
                  Text('Activity Tab', style: TextStyle(color: Colors.white))),
          // Reviews Tab - placeholder
          Center(
              child:
                  Text('Reviews Tab', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
