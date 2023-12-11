import 'package:flutter/material.dart';

import '../provider/vg_image_asset_provider.dart';

typedef WidgetBuilder = Widget Function(ImageProvider value);

class ImageBuilder extends StatelessWidget {
  final String imageKey;
  final WidgetBuilder builder;
  final String placeHolder;
  final String? noImagePlaceholder;
  final bool forceUpdateCache;
  const ImageBuilder(this.imageKey,
      {Key? key,
      required this.builder,
      required this.placeHolder,
      this.noImagePlaceholder,
      this.forceUpdateCache = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider?>(
      initialData:
          VGImageAssetProvider.instance.getPlaceholder(key: placeHolder),
      future: VGImageAssetProvider.instance
          .getImage(imageKey, forceUpdateCache: forceUpdateCache),
      builder: (BuildContext context, AsyncSnapshot<ImageProvider?> snapshot) {
        var imageProvider = snapshot.data ??
            VGImageAssetProvider.instance
                .getPlaceholder(key: noImagePlaceholder);
        return builder(imageProvider);
      },
    );
  }
}
