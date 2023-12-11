import 'package:flutter/material.dart';
import 'package:image_asset_provider/widget/image_builder.dart';
import 'package:test_app/widgets/grid_image_view/grid_image_view_util.dart';

class ImageScreen extends StatelessWidget {
  static String id = "/imageScreen";

  final ImageItem imageItem;

  const ImageScreen({Key? key, required this.imageItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.grey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Image key: ${imageItem.imageKey}",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
              Expanded(
                child: ImageBuilder(
                  imageItem.imageKey,
                  builder: (ImageProvider imageProvider) {
                    return Image(image: imageProvider);
                  },
                  placeHolder: imageItem.placeholder,
                  noImagePlaceholder: imageItem.noImagePlaceholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
