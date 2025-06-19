class PhotoPackage {
  final String id;
  final String title;
  final String description;
  final int price;
  final String coverImage;
  final List<String> detailImages;
  final List<String> userShowcaseImages;
  final bool isPetOnly;

  PhotoPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.coverImage,
    required this.detailImages,
    required this.userShowcaseImages,
    required this.isPetOnly,
  });
}
