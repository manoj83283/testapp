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
      "description": "Birthday decoration, cakes, games",
    },
    {
      "name": "Weddings",
      "key": "wedding",
      "icon": Icons.favorite,
      "color": Colors.red,
      "description": "Wedding planners, catering, photography",
    },
    {
      "name": "Corporate Events",
      "key": "corporate",
      "icon": Icons.business_center,
      "color": Colors.blue,
      "description": "Office events, conferences",
    },
    {
      "name": "College Events",
      "key": "college",
      "icon": Icons.school,
      "color": Colors.deepPurple,
      "description": "Freshers, farewell",
    },
  ];

  List<Map<String, dynamic>> get filteredCategories {
    if (searchQuery.trim().isEmpty) {
      return eventCategories;
    }

    final query = searchQuery.toLowerCase();

    return eventCategories.where((category) {
      return category["name"].toLowerCase().contains(query) ||
          category["description"].toLowerCase().contains(query);
    }).toList();
  }

  void openNearbyServices(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NearbyServicesScreen(
          categoryName: category["name"],
          categoryKey: category["key"],
        ),
      ),
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

      /// ✅ APPBAR
      appBar: AppBar(
        title: const Text("EventEase"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),

          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
              const Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    "0",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, "/profile");
            },
          ),
        ],
      ),

      /// ✅ BODY
      body: Column(
        children: [

          /// ✅ LOCATION + SEARCH ROW 🔥
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [

                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.orange),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Deliver to"),
                          Text(
                            "Hyderabad - Kondapur",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    )
                  ],
                ),

                const SizedBox(height: 12),

                /// ✅ SEARCH FIELD
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
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ✅ TITLE ROW
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
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          /// ✅ GRID
          Expanded(
            child: categories.isEmpty
                ? const Center(child: Text("No categories found"))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
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
                      final color = category["color"];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => openNearbyServices(category),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    color.withOpacity(0.15),
                                child: Icon(
                                  category["icon"],
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                category["name"],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                category["description"],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
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
