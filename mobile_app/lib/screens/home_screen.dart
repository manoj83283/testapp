import 'package:flutter/material.dart';
import 'nearby_services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  final List<Map<String, dynamic>> eventCategories = [
    {
      "name": "Birthday Parties",
      "key": "birthday",
      "icon": Icons.celebration,
      "color": Colors.pink,
      "description": "Birthday decoration, cakes, games, anchors",
    },
    {
      "name": "Weddings",
      "key": "wedding",
      "icon": Icons.favorite,
      "color": Colors.red,
      "description": "Wedding planners, decorators, catering, photography",
    },
    {
      "name": "Corporate Events",
      "key": "corporate",
      "icon": Icons.business_center,
      "color": Colors.blue,
      "description": "Office events, conferences, team outings",
    },
    {
      "name": "College Events",
      "key": "college",
      "icon": Icons.school,
      "color": Colors.deepPurple,
      "description": "Freshers, farewell, graduation parties",
    },
    {
      "name": "House Parties",
      "key": "house_party",
      "icon": Icons.home,
      "color": Colors.orange,
      "description": "Home decoration, food, music, party setup",
    },
    {
      "name": "Concerts / Music Events",
      "key": "concert",
      "icon": Icons.music_note,
      "color": Colors.indigo,
      "description": "Music bands, DJs, stage, sound systems",
    },
    {
      "name": "Kids Events",
      "key": "kids",
      "icon": Icons.child_care,
      "color": Colors.green,
      "description": "Kids games, magic shows, cartoon themes",
    },
    {
      "name": "Cultural Events",
      "key": "cultural",
      "icon": Icons.groups,
      "color": Colors.teal,
      "description": "Community functions, cultural shows, festivals",
    },
    {
      "name": "Outdoor Events",
      "key": "outdoor",
      "icon": Icons.beach_access,
      "color": Colors.cyan,
      "description": "Outdoor events, destination parties, resort events",
    },
  ];

  List<Map<String, dynamic>> get filteredCategories {
    if (searchQuery.trim().isEmpty) {
      return eventCategories;
    }

    final query = searchQuery.toLowerCase().trim();

    return eventCategories.where((category) {
      final name = category["name"].toString().toLowerCase();
      final description = category["description"].toString().toLowerCase();

      return name.contains(query) || description.contains(query);
    }).toList();
  }

  void openNearbyServices(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NearbyServicesScreen(
          categoryName: category["name"].toString(),
          categoryKey: category["key"].toString(),
        ),
      ),
    );
  }

  void showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$featureName coming soon")),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final categories = filteredCategories;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("EventEase"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => showComingSoon("Notifications"),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => showComingSoon("Profile"),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Plan your perfect event",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Find decorators, caterers, photographers, DJs and more",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search events or services",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchQuery = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Row(
              children: [
                const Text(
                  "Event Categories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "${categories.length} found",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? const Center(child: Text("No categories found"))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.88,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final Color categoryColor = category["color"] as Color;

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => openNearbyServices(category),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 31,
                                backgroundColor:
                                    categoryColor.withOpacity(0.12),
                                child: Icon(
                                  category["icon"] as IconData,
                                  color: categoryColor,
                                  size: 33,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                category["name"].toString(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category["description"].toString(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: categoryColor,
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
    );
  }
}