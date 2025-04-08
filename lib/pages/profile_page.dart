import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../screens/trail_overview_screen.dart';
import 'newhome_page.dart';
import 'annotate_page.dart';
import 'search_page.dart';
import 'saved_trails_page.dart';
import 'edit_profile_page.dart';

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
  List<String> _userImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    const stickyThreshold = 300.0;
    if (_scrollController.offset > stickyThreshold && !_showStickyTabs) {
      setState(() => _showStickyTabs = true);
    } else if (_scrollController.offset <= stickyThreshold && _showStickyTabs) {
      setState(() => _showStickyTabs = false);
    }
  }

  Future<void> _fetchUserDetails() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      try {
        final userResponse = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', userId)
            .single();

        final trailsResponse = await Supabase.instance.client
            .from('trails')
            .select('id, name, distance_meters, duration_seconds, created_at')
            .eq('user_id', userId);

        await fetchUserImages(userId);

        setState(() {
          _userDetails = {
            ...userResponse,
            'formatted_distance':
                formatDistance(userResponse['total_distance'] ?? 0),
            'formatted_time':
                formatDuration(userResponse['total_hiking_time'] ?? 0)
          };
          _userTrails = trailsResponse;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> fetchUserImages(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_images')
          .select('image_path')
          .eq('user_id', userId);

      setState(() {
        _userImages = response
            .map<String>((record) => record['image_path'] as String)
            .toList();
      });
    } catch (e) {
      debugPrint('Error fetching user images: $e');
    }
  }

  String getImageUrl(String imagePath) {
    return Supabase.instance.client.storage
        .from('images')
        .getPublicUrl(imagePath);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.green),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () async => await logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(child: _buildProfileHeader()),
                SliverToBoxAdapter(child: _buildTabBar()),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildActivityTab(),
                _buildPhotosTab(),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AnnotatePage()),
          ),
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
              icon: const Icon(Icons.home_outlined),
              color: Colors.grey,
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              color: Colors.grey,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              ),
            ),
            const SizedBox(width: 48), // Space for the FAB
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              color: Colors.grey,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SavedTrailsPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
                backgroundImage: _userDetails?['avatar_url'] != null
                    ? NetworkImage(_userDetails!['avatar_url'])
                    : const AssetImage('assets/images/profile.jpg')
                        as ImageProvider,
                backgroundColor: Colors.green.withOpacity(0.2),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _userDetails?['username'] ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow:
                                TextOverflow.ellipsis, // Prevents text overflow
                          ),
                        ),
                        const SizedBox(
                            width: 1), // Small gap between text and button
                        IconButton(
                          icon: const Icon(Icons.edit_note,
                              color: Colors.green, size: 23),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            if (_userDetails != null && mounted) {
                              final updatedUser = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(
                                    currentUserData: _userDetails!,
                                  ),
                                ),
                              );
                              if (updatedUser != null && mounted) {
                                setState(() {
                                  _userDetails = {
                                    ..._userDetails!,
                                    ...updatedUser,
                                    'formatted_distance': formatDistance(
                                        _userDetails!['total_distance'] ?? 0),
                                    'formatted_time': formatDuration(
                                        _userDetails!['total_hiking_time'] ??
                                            0),
                                  };
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.hiking, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _userDetails?['hiking_experience'] ?? 'Loading...',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
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
                const Text(
                  'STATS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.terrain,
                      _userDetails?['formatted_distance'] ?? '0 km',
                      'Distance',
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.green.withOpacity(0.3),
                    ),
                    _buildStatItem(
                      Icons.timer,
                      _userDetails?['formatted_time'] ?? '0 hr',
                      'Time',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
        tabs: const [
          Tab(text: 'Activity'),
          Tab(text: 'Photos'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.green));
    }
    if (_userTrails.isEmpty) {
      return const Center(
          child:
              Text('No trails found', style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userTrails.length,
      itemBuilder: (context, index) {
        final trail = _userTrails[index];
        final imageUrl = _getImageUrlForTrail(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildActivityCard(
            trail['name'],
            trail['distance_meters'],
            '${DateTime.now().difference(DateTime.parse(trail['created_at'])).inDays} days ago',
            imageUrl,
            trail['id'],
          ),
        );
      },
    );
  }

  List<String> _getStaticImageUrls() {
    return [
      'https://overatours.com/wp-content/uploads/2022/04/istockphoto-658384428-612x612-1.jpg',
      'https://overatours.com/wp-content/uploads/2021/11/Horton-Plain-National-Park-Trek-Things-to-do-in-Nuwara-Eliya.jpg',
      'https://media-hosting.imagekit.io//c6be2f189c554a88/tim-stief-YFFGkE3y4F8-unsplash.jpg?Expires=1837166660&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=oHytkUjYQys4RRDj2yxEmSqv1UcMGGDhzzLR24wA2Mwab~EXAVCEl0P6n2gvG1UsUaZKH3hPgeg76nDMMA3zjqTbxIz-4H-BvSJBp3VTn6Nm1ANolxSo61SC6JU~JUnxFetwF43X0T2D~h30YgZ435sbWL2cLg1X0z3X0wPSGLLUMAafXwCEIwFOYX1zS45YT6I98Xt4dFaHOrUSoLE4EeqlfsJjHdcg3VupodvujxpIBI53FONNdo-zHHAiP8AfwFassMYbyMlwPqVwRKCmkvKoPjz~UmcQAlo0h3t4xMEmMRd7F9FZmYQi4nkwFz97LfIBQ833j-zESBFAwrQhMw__',
      'https://media-hosting.imagekit.io//f511187b4077490b/hintersee-3601004_1280.jpg?Expires=1837164860&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=Aull5F7JSOm6ogZbsk-AcSSlD796vAvLzEbHy~k7CJaIAg7f7x79x9CZj68hZNVCMVdp3HqUiiv7sl8lrr16w-OQr4wkbbHVud1Reh9J48F75OEBvoMuTDlJcELvfouxOIeMKvQn7xrdYkhLwrs9PjhtvCWIpESqjeQS0UV~fmyYxTd6k-I64qly1A-EhbGFATZuBKSubA56TKyow8EkF9PQ6iB5Fhrobqtqtx-y4wjSX-t2M0fb1ldipO9~yMWgKKgJBzphv5YyVWBXwmILBDsLOaHdZlZbX7K-G0NsmeDGUDUQDdKrRqVmp8B2ZryVEhJZ1qJhBUn822V4swURnA__',
      'https://media-hosting.imagekit.io//6528056a5e9f4d50/tree-1715298_1280.jpg?Expires=1837165845&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=E3eYUEAOLodCYLBDZXcAs~rpZs4E5vfXEVxPWXtjAhXI0hQsE2l55hPCULC4ZSnqiFDWMqxPExER3FqBrgKr7m7Ahr-jqOWCZDtPKibNDwH-68HGhithAFEeMAJgfEq2qvGo3Mcb5gcGJVCrFCfoXDAgJsVFMc-YQ~cU~uRjxOtInMfiFPrV2iQdZfyHhY7G7p7qriXuTCGQ7btItx-9Rs30vv~NW7qMTGv3qYo0GGKGFeE1sAOEdohPPvm-BramBtDNn1LqE9dz7fAymETSMPFe1quuUIE2YIHKhWqyMwekLxJRbDEZ0cgRF-vcG7N9p89uo0xK4Y~qttg5KXT9qw__',
      'https://media-hosting.imagekit.io//f5ad663817324e74/jeremy-bishop-dvACrXUExLs-unsplash.jpg?Expires=1837166615&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=oqxgG3-JxqPGBxFNsHoE5dK0OQ2CCLG9pRk3VxvPCVuF7ikW4sLpFJjt2DlD63nEhEhre0ivu5FAMAFRoKTLlOCVj84OFLR2R9PhEanJlNY0kIMIxtLu~bN88cocIMfOoeZfrvq2PNkEebtDm~e~itGs7BdhfAov0LTLUGOw-H7-w0KaWJ6dvoFrLPyLNq0q~vWlXgtbfeedkStNsCyUxuxYxXqEeXTiaRa2Y5xtV0mQA6cfzuJNVI4-zPGKC42ZWfDiRTCX6xApsldePTnb2IR~7gUggLqnCk90VN6MBhGywkdmmrO4GEDV0UGcpu44SDiYcOXp85XTJjve8GQx7Q__',
    ];
  }

  String _getImageUrlForTrail(int index) {
    final imageUrls = _getStaticImageUrls();
    return imageUrls[index % imageUrls.length];
  }

  Widget _buildPhotosTab() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.green));
    }
    if (_userImages.isEmpty) {
      return _buildEmptyState(Icons.photo_library_outlined, 'No photos found',
          'Photos you upload will appear here');
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: _userImages.length,
        itemBuilder: (context, index) => _buildPhotoCard(_userImages[index]),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.delayed(
          const Duration(milliseconds: 300), () => _getMockReviews()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading reviews',
                  style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(Icons.reviews_outlined, 'No reviews yet',
              'Be the first to review trails');
        }

        final reviews = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
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

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String trailName, double distanceMeters,
      String time, String imageUrl, String trailId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrailOverviewScreen(
              trailId: trailId,
            ),
          ),
        );
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
                    'Distance: ${formatDistance(distanceMeters)}', // Use formatDistance here
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

  Widget _buildPhotoCard(String imagePath) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1E1E1E),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            getImageUrl(imagePath),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                  child: CircularProgressIndicator(color: Colors.green));
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: Center(
                    child: Icon(Icons.broken_image,
                        size: 50, color: Colors.grey[600])),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
      String trailName, double rating, String review, String time) {
    return Card(
      elevation: 3,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trailName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to the trail details page
                  },
                  child: const Icon(Icons.arrow_forward, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                const SizedBox(width: 8),
                Text(
                  rating.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review,
              style: TextStyle(fontSize: 16, color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
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

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
      ],
    );
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse('http://13.53.173.93:5000/api/v1/logout'),
        headers: {'Cookie': 'SessionID=${prefs.getString('accessToken')}'},
      );

      if (response.statusCode == 200) {
        await prefs.remove('accessToken');
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/landing', (Route<dynamic> route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout error: $e')),
      );
    }
  }
}

String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final secs = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return "$hours hr ${twoDigits(minutes)} min";
  } else if (minutes > 0) {
    return "$minutes min ${twoDigits(secs)} s";
  } else {
    return "$secs s";
  }
}

String formatDistance(double meters) {
  if (meters >= 1000) {
    int km = (meters ~/ 1000);
    int remainingMeters = (meters % 1000).toInt();
    return remainingMeters == 0 ? "$km km" : "$km km $remainingMeters m";
  } else {
    return "${meters.toInt()} m";
  }
}
