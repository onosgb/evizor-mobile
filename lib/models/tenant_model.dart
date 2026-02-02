class Tenant {
  final String id;
  final String slug;
  final String schemaName;
  final String province;
  final bool isActive;
  final DateTime updatedAt;

  Tenant({
    required this.id,
    required this.slug,
    required this.schemaName,
    required this.province,
    required this.isActive,
    required this.updatedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      slug: json['slug'] as String,
      schemaName: json['schemaName'] as String,
      province: json['province'] as String,
      isActive: json['isActive'] as bool,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'schemaName': schemaName,
      'province': province,
      'isActive': isActive,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Tenant(id: $id, province: $province, slug: $slug)';
  }
}
