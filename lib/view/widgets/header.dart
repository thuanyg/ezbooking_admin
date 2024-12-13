import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezbooking_admin/view/page/homepage.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final Function(BuildContext) onTapMenu;
  final GlobalKey<HomepageState> homeKey;

  const Header({super.key, required this.onTapMenu, required this.homeKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => onTapMenu(context),
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 36,
          ),
        ),
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Search here',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                // Show widget search results
                homeKey.currentState?.searchQuery = value.trim();
                homeKey.currentState?.isSearchResult.value = false;
                homeKey.currentState?.isSearchResult.value = true;
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildIconButton(Icons.notifications_outlined),
        const SizedBox(width: 16),
        const CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(
            '',
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.grey),
    );
  }
}
