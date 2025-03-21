import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/navigation_page.dart';
import '../pages/navigatetotrail.dart';
import '../pages/download_page.dart';

class TrailOverviewScreen extends StatefulWidget {
  final String trailId;

  const TrailOverviewScreen({
    super.key,
    required this.trailId,
  });

  @override
  _TrailOverviewScreenState createState() => _TrailOverviewScreenState();
}

class _TrailOverviewScreenState extends State<TrailOverviewScreen> {
  final _commentController = TextEditingController();
  double _userRating = 0;
  late Future<Trail> _futureTrail;

  @override
  void initState() {
    super.initState();
    _futureTrail = ApiService.getTrailById(widget.trailId);
  }

  void _submitReview() {
    if (_commentController.text.isEmpty || _userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add both rating and comment'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // TODO: Implement review submission to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review added successfully'),
        backgroundColor: Color(0xFF4eae55),
      ),
    );
  }

  Future<void> _downloadMap(String mapUrl) async {
    final url = Uri.parse(mapUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not download map'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4eae55),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4eae55),
          secondary: const Color(0xFF4eae55),
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: const Color(0xFF4eae55), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4eae55),
            foregroundColor: Colors.white,
            elevation: 3,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        body: FutureBuilder<Trail>(
          future: _futureTrail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4eae55),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text(
                  'No trail details found',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            } else {
              final trail = snapshot.data!;

              // Use mock reviews (keep this part unchanged)
              final mockReviews = [
                Review(
                  id: '1',
                  userId: 'user1',
                  userName: 'Sophia',
                  userImage: 'https://randomuser.me/api/portraits/women/1.jpg',
                  date: 'Jan 2022',
                  rating: 5,
                  comment: 'Great hike, beautiful views of the bay area.',
                  likes: 12,
                ),
                Review(
                  id: '2',
                  userId: 'user2',
                  userName: 'Ava',
                  userImage: 'https://randomuser.me/api/portraits/women/2.jpg',
                  date: 'Dec 2021',
                  rating: 5,
                  comment:
                      'Nice trail with a lot of shade. The view was amazing.',
                  likes: 8,
                ),
                Review(
                  id: '3',
                  userId: 'user3',
                  userName: 'Emma',
                  userImage: 'https://randomuser.me/api/portraits/women/3.jpg',
                  date: 'Nov 2021',
                  rating: 5,
                  comment:
                      'Love hiking here. It\'s not too long and it\'s really pretty.',
                  likes: 7,
                ),
              ];

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: const Color(0xFF121212),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            trail.imageUrl ??
                                'https://upload.wikimedia.org/wikipedia/commons/1/1d/Jaela5.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/trail2.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          // Dark overlay for better text visibility
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  trail.name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.directions,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NavigatetoTrailPage(
                                        trailId: trail.id, // Pass the trail ID
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                  'Difficulty', trail.difficultyLevel),
                              _buildInfoRow('Distance',
                                  _formatDistance(trail.distanceMeters)),
                              _buildInfoRow('Duration',
                                  _formatDuration(trail.durationSeconds)),
                              _buildInfoRow('District', trail.district),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DownloadMapPage(
                                                    trailId: trail.id),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.map,
                                          color: Colors.white),
                                      label: const Text('Download'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        backgroundColor:
                                            const Color(0xFF4eae55),
                                        foregroundColor: Colors.white,
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Add spacing between the buttons
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NavigationPage(
                                              trailId:
                                                  trail.id, // Pass the trail ID
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.navigation,
                                          color: Colors.white),
                                      label: const Text('Navigate'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        backgroundColor:
                                            const Color(0xFF4eae55),
                                        foregroundColor: Colors.white,
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Reviews',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildReviewInput(),
                              const SizedBox(height: 20),
                              ...mockReviews
                                  .map((review) => _buildReviewCard(review)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    // Format based on available time units
    if (hours > 0) {
      return "$hours hr ${twoDigits(minutes)} min ${twoDigits(secs)} s";
    } else if (minutes > 0) {
      return "$minutes min ${twoDigits(secs)} s";
    } else {
      return "$secs s";
    }
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      // Convert to kilometers
      int km = (meters ~/ 1000); // Integer division to get whole kilometers
      int remainingMeters = (meters % 1000).toInt(); // Get remaining meters

      if (remainingMeters == 0) {
        // If it's exactly X kilometers
        return "$km km";
      } else {
        // If there are remaining meters
        return "$km km $remainingMeters m";
      }
    } else {
      // Less than 1 km, just show meters
      return "${meters.toInt()} m";
    }
  }

  Widget _buildReviewInput() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Your Review',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _userRating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF4eae55),
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _userRating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Write your review...',
                hintStyle: TextStyle(color: Colors.white54),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                child: const Text(
                  'Submit Review',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(review.userImage),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      review.date,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF4eae55),
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.thumb_up_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    // TODO: Implement like functionality
                  },
                ),
                Text(
                  '${review.likes}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
