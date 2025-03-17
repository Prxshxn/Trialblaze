import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/blog.dart';

class BlogDetailPage extends StatelessWidget {
  final Blog blog;

  const BlogDetailPage({Key? key, required this.blog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background
      body: SafeArea(
        child: Column(
          children: [
            // Top image section with header
            Stack(
              children: [
                // Blog image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.asset(
                    blog.imageUrl,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Navigation buttons
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5), // Light background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black, // Black icon
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                // Bookmark button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5), // Light background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Colors.black, // Black icon
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
                // Title overlay
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Text(
                    blog.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Black text
                    ),
                  ),
                ),
              ],
            ),

            // Author and time info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.black54, // Dark gray icon
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Trailblaze',
                    style: TextStyle(
                      color: Colors.black, // Black text
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    color: Colors.black54, // Dark gray icon
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    blog.readTime,
                    style: const TextStyle(
                      color: Colors.black87, // Dark gray text
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Light gray background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    blog.content,
                    style: const TextStyle(
                      color: Colors.black87, // Dark gray text
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
