class CarManufacturer {
  final String name;
  final String slug;
  final String thumb;

  CarManufacturer({
    required this.name,
    required this.slug,
    required this.thumb,
  });

  factory CarManufacturer.fromJson(Map<String, dynamic> json) {
    return CarManufacturer(
      name: json['name'] as String,
      slug: json['slug'] as String,
      thumb: json['thumb'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'slug': slug, 'thumb': thumb};
  }
}
