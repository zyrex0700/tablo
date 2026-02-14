class TestimonialItem {
  const TestimonialItem({
    required this.id,
    required this.companyName,
    required this.personName,
    required this.role,
    required this.quote,
    required this.avatarUrl,
  });

  final String id;
  final String companyName;
  final String personName;
  final String role;
  final String quote;
  final String avatarUrl;

  String get safeAvatarUrl {
    if (avatarUrl.startsWith('http://')) {
      return avatarUrl.replaceFirst('http://', 'https://');
    }
    return avatarUrl;
  }

  factory TestimonialItem.fromJson(Map<String, dynamic> json) {
    return TestimonialItem(
      id: json['id']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      personName: json['person_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      quote: json['quote']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
    );
  }
}
