class ProvinceModel {
  const ProvinceModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String imageUrl;

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}
