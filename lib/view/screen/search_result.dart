import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/models/category.dart';
import 'package:ezbooking_admin/models/organizer.dart';
import 'package:ezbooking_admin/models/user.dart';
import 'package:ezbooking_admin/view/page/homepage.dart';
import 'package:flutter/material.dart';

class SearchResult extends StatefulWidget {
  final String query;
  final GlobalKey<HomepageState> homeKey;

  const SearchResult({super.key, required this.query, required this.homeKey});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search methods for each collection
  Future<List<UserModel>> _searchUsers(String query) async {
    try {
      // Search across multiple fields
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThan: '${query}\uf8ff')
          .limit(10)
          .get();

      return userSnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<List<Organizer>> _searchOrganizers(String query) async {
    try {
      // Search across multiple fields
      QuerySnapshot organizerSnapshot = await _firestore
          .collection('organizers')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}\uf8ff')
          .get();

      return organizerSnapshot.docs
          .map((doc) => Organizer.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching organizers: $e');
      return [];
    }
  }

  Future<List<Category>> _searchCategories(String query) async {
    try {
      // Search categories
      QuerySnapshot categorySnapshot = await _firestore
          .collection('categories')
          .where('categoryName', isGreaterThanOrEqualTo: query)
          .where('categoryName', isLessThan: '${query}z')
          .limit(10)
          .get();

      return categorySnapshot.docs
          .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching categories: $e');
      return [];
    }
  }

  // Reusable method to build a search result section
  Widget _buildSearchSection<T>({
    required bool isDesktop,
    required String title,
    required List<T> items,
    required Widget Function(T) itemBuilder,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 20 : 16,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(
            color: Colors.white24,
            height: 1,
          ),
          itemBuilder: (context, index) => itemBuilder(items[index]),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Breakpoints.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: FutureBuilder(
        future: Future.wait([
          _searchUsers(widget.query),
          _searchOrganizers(widget.query),
          _searchCategories(widget.query),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // Check if data is available
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error occurred while searching',
                style: TextStyle(
                    color: Colors.white, fontSize: isDesktop ? 18 : 14),
              ),
            );
          }

          // Extract search results
          final List<UserModel> users = snapshot.data?[0] ?? [];
          final List<Organizer> organizers = snapshot.data?[1] ?? [];
          final List<Category> categories = snapshot.data?[2] ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        widget.homeKey.currentState?.isSearchResult.value =
                            false;
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Search results',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Users Section
                _buildSearchSection<UserModel>(
                  isDesktop: isDesktop,
                  title: 'Users (${users.length})',
                  items: users,
                  itemBuilder: (user) => ListTile(
                    leading: user.avatarUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.avatarUrl!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(
                      user.fullName ?? 'No Name',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      user.email ?? 'No Email',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),

                // Organizers Section
                _buildSearchSection<Organizer>(
                  isDesktop: isDesktop,
                  title: 'Organizers (${organizers.length})',
                  items: organizers,
                  itemBuilder: (organizer) => ListTile(
                    leading: organizer.avatarUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(organizer.avatarUrl!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.business),
                          ),
                    title: Text(
                      organizer.name ?? 'No Name',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      organizer.email ?? 'No Email',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),

                // Categories Section
                _buildSearchSection<Category>(
                  isDesktop: isDesktop,
                  title: 'Categories (${categories.length})',
                  items: categories,
                  itemBuilder: (category) => ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.category),
                    ),
                    title: Text(
                      category.categoryName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Created: ${category.createdAt}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),

                // No results handling
                if (users.isEmpty && organizers.isEmpty && categories.isEmpty)
                  Center(
                    child: Text(
                      'No results found for "${widget.query}"',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isDesktop ? 18 : 14,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Note: For efficient searching, you should create a pre-processed
// searchKeywords field in Firestore that contains lowercase versions
// of searchable fields to enable better text search
