import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'blog_detail_page.dart';
import '../models/blog.dart';
import '../data/blog_data.dart';

class BlogsListPage extends StatefulWidget {
  const BlogsListPage({Key? key}) : super(key: key);

  @override
  _BlogsListPageState createState() => _BlogsListPageState();
}

class _BlogsListPageState extends State<BlogsListPage> {
  TextEditingController searchController = TextEditingController();
  List<Blog> filteredBlogs = [];

  @override
  void initState() {
    super.initState();
    filteredBlogs = blogsList;
  }

  void filterBlogs(String query) {
    setState(() {
      filteredBlogs = blogsList
          .where((blog) =>
              blog.title.toLowerCase().contains(query.toLowerCase()) ||
              blog.excerpt.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black, // Black icon
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Stories from the Trail',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Black text
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Light gray background
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: filterBlogs,
                  style: const TextStyle(color: Colors.black), // Black text
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey), // Gray hint text
                    prefixIcon:
                        Icon(Icons.search, color: Colors.grey), // Gray icon
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Blog list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredBlogs.length,
                itemBuilder: (context, index) {
                  final blog = filteredBlogs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogDetailPage(blog: blog),
                        ),
                      );
                    },
                    child: Container(
                      height: 160,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white, // White background
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Blog image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              blog.imageUrl,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black
                                      .withOpacity(0.3), // Lighter gradient
                                ],
                              ),
                            ),
                          ),
                          // Blog info
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  blog.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // White text
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${blog.publishDate.year} - ${blog.readTime}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            Colors.white70, // Light gray text
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // User avatar (right corner)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[800], // Dark gray icon
                              ),
                            ),
                          ),
                          // Optional: Season icon (left corner)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: _getSeasonIcon(blog.title),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSeasonIcon(String title) {
    if (title.toLowerCase().contains('summer')) {
      return const Icon(Icons.wb_sunny, color: Colors.black); // Black icon
    } else if (title.toLowerCase().contains('winter')) {
      return const Icon(Icons.ac_unit, color: Colors.black); // Black icon
    } else if (title.toLowerCase().contains('spring')) {
      return const Icon(Icons.local_florist, color: Colors.black); // Black icon
    } else if (title.toLowerCase().contains('autumn') ||
        title.toLowerCase().contains('fall')) {
      return const Icon(Icons.eco, color: Colors.black); // Black icon
    }
    return const Icon(Icons.landscape, color: Colors.black); // Black icon
  }
}
