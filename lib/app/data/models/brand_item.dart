class BrandItem {
  const BrandItem({
    required this.id,
    required this.brandName,
    required this.logoUrl,
  });

  final String id;
  final String brandName;
  final String logoUrl;

  factory BrandItem.fromJson(Map<String, dynamic> json) {
    return BrandItem(
      id: json['id']?.toString() ?? '',
      brandName: json['brand_name']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString() ?? '',
    );
  }
}
