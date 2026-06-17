import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nearby_services_screen.dart';
import '../widgets/language_selector.dart';
import '../localization/app_localizations.dart'; 
import 'login_screen.dart';

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
    if (searchQuery.trim().isEmpty) return eventCategories;

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
  Widget build(BuildContext context) {
    final categories = filteredCategories;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ✅ ✅ ✅ DRAWER WITH FIXES
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                AppLocalizations.of(context).translate("customer_panel"),
                style: const TextStyle(fontSize: 18),
              ),
            ),

            /// ✅ LANGUAGE SWITCHER
            const LanguageSelector(),

            /// ✅ SETTINGS
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                AppLocalizations.of(context).translate("settings"),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/settings");
              },
            ),

            /// ✅ ✅ ✅ FINAL LOGOUT FIX
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                AppLocalizations.of(context).translate("logout"),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();

                await prefs.remove("token");
                await prefs.remove("role");

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login_user', // ✅ ROUTE BASED NAVIGATION
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

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
          /// ✅ LOCATION + SEARCH
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
                        children: [
                          Text(
                            AppLocalizations.of(context)
                                .translate("deliver_to"),
                          ),
                          const Text(
                            "Hyderabad - Kondapur",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
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
                    hintText: AppLocalizations.of(context)
                        .translate("search_hint"),
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

          /// ✅ TITLE
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)
                      .translate("event_categories"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text("${categories.length}"),
              ],
            ),
          ),

          /// ✅ GRID
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate("no_categories"),
                    ),
                  )
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
                                color: Colors.black.withValues(alpha: 0.05),
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