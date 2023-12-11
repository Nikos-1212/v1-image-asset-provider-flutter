import 'package:flutter/material.dart';
import 'package:image_asset_provider/image_asset_provider.dart';

import 'grid_image_view_util.dart';

typedef OnTappedImage = void Function(int index);

class GridImageView extends StatefulWidget {
  final List<ImageItem> items;
  final OnTappedImage onTappedImage;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final int crossAxisCount;
  final double heightItem;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ImageDecorator? imageDecorator;

  const GridImageView(
      {Key? key,
      required this.items,
      required this.onTappedImage,
      this.physics,
      this.scrollDirection = Axis.vertical,
      this.crossAxisCount = 2,
      this.heightItem = 100.0,
      this.crossAxisSpacing = 8.0,
      this.mainAxisSpacing = 8.0,
      this.imageDecorator})
      : super(key: key);

  @override
  State<GridImageView> createState() => _GridImageViewState();
}

class _GridImageViewState extends State<GridImageView> {
  Widget _gridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: widget.physics,
      scrollDirection: widget.scrollDirection,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisCount: widget.crossAxisCount,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => widget.onTappedImage(index),
          child: Card(
            color: Colors.grey,
            margin: EdgeInsets.zero,
            elevation:
                widget.imageDecorator?.elevation, // Add a shadow to the card.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  widget.imageDecorator?.radius ??
                      0), // Add a radius to the card.
            ),
            child: ImageBuilder(
              widget.items[index].imageKey,
              builder: (ImageProvider imageProvider) {
                return Image(image: imageProvider);
              },
              placeHolder: widget.items[index].placeholder,
              noImagePlaceholder: widget.items[index].noImagePlaceholder,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.scrollDirection == Axis.horizontal
        ? SizedBox(
            height: widget.heightItem * widget.crossAxisCount,
            child: _gridView(),
          )
        : _gridView();
  }
}
