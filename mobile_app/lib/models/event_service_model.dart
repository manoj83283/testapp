class EventServiceModel {
  final String name;
  final String icon;
  final String category;
  final String description;

  EventServiceModel({
    required this.name,
    required this.icon,
    required this.category,
    required this.description,
  });

  factory EventServiceModel.fromJson(Map<String, dynamic> json) {
    return EventServiceModel(
      name: json['name'],
      icon: json['icon'],
      category: json['category'],
      description: json['description'] ?? '',
    );
  }
}