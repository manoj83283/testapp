class ProviderModel {
  final String id;
  final String name;
  final String email;
  final String serviceType;
  final String description;
  final double rating;
  final double pricePerHour;
  final double pricePerDay;
  final String city;
  final String state;
  final String country;
  final List<String> photos;
  final List<String> videos;

  ProviderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.serviceType,
    required this.description,
    required this.rating,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.city,
    required this.state,
    required this.country,
    required this.photos,
    required this.videos,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] ?? {};
    final media = json['media'] ?? {};
    return ProviderModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      serviceType: json['serviceType'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      city: loc['city'] ?? '',
      state: loc['state'] ?? '',
      country: loc['country'] ?? '',
      photos: List<String>.from(media['photos'] ?? []),
      videos: List<String>.from(media['videos'] ?? []),
    );
  }
}