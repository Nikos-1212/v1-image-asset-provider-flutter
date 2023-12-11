class ImageDecorator {
  final double? elevation;
  final double? radius;

  ImageDecorator({this.elevation = 0.0, this.radius = 0.0});
}

class ImageItem {
  final String imageKey;
  final String placeholder;
  final String? noImagePlaceholder;

  ImageItem(this.imageKey,
      {required this.placeholder, this.noImagePlaceholder});
}
