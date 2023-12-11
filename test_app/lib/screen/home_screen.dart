import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:framework_contracts_flutter/framework_contracts_flutter.dart';
import 'package:image_asset_provider/gen/assets.gen.dart';
import 'package:test_app/screen/image_screen.dart';
import 'package:test_app/widgets/grid_image_view/grid_image_view.dart';
import 'package:test_app/widgets/grid_image_view/grid_image_view_util.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ImageItem> _actualItems() {
    var items = [
      ImageItem("random-asset.png",
          placeholder: Assets.images.placeholder.keyName,
          noImagePlaceholder: Assets.images.noImagePlaceholder.keyName),
      ImageItem("410.svg",
          placeholder: Assets.images.placeholder.keyName,
          noImagePlaceholder: Assets.images.noImagePlaceholder.keyName),
      ImageItem("410333.svg",
          placeholder: Assets.images.placeholder.keyName,
          noImagePlaceholder: Assets.images.noImagePlaceholder.keyName),
      ImageItem("1.jpeg",
          placeholder: Assets.images.placeholder.keyName,
          noImagePlaceholder: Assets.images.noImagePlaceholder.keyName),
      ImageItem("2.jpeg",
          placeholder: Assets.images.placeholder.keyName,
          noImagePlaceholder: Assets.images.noImagePlaceholder.keyName),
      ImageItem("3.jpeg",
          placeholder: Assets.images.placeholder.keyName,
          noImagePlaceholder: Assets.images.noImagePlaceholder.keyName),
      ImageItem("9999.jpeg",
          placeholder: Assets.images.placeholder.keyName,
          noImagePlaceholder: Assets.images.noImagePlaceholder.keyName)
    ];
    items.addAll(_generateFromAssets());
    return items;
  }

  List<ImageItem> _generateFromAssets() {
    var appAndDevices = Assets.images.appAndDevices.values;
    var getActiveGoal = Assets.images.getActiveGoal.values;
    var loginAndRegistration = Assets.images.loginAndRegistration.values;

    List<AssetGenImage> allAssets = [];
    allAssets.addAll(appAndDevices);
    allAssets.addAll(getActiveGoal);
    allAssets.addAll(loginAndRegistration);

    var items = allAssets.map((e) {
      return ImageItem(e.keyName,
          placeholder: Assets.images.placeholder.keyName,
          noImagePlaceholder: Assets.images.noImagePlaceholder.keyName);
    }).toList();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Image Provider"),
        ),
        body: Container(
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: () {
                  Modular.get<ImageAssetProvider>().invalidateCache();
                },
                child: Text("Invalidate Cache"),
              ),
              ElevatedButton(
                onPressed: () {
                  Modular.get<ImageAssetProvider>()
                      .invalidateCache(key: "1.jpeg");
                },
                child: Text("Invalidate Cache for 1.jpeg"),
              ),
              ElevatedButton(
                onPressed: () {
                  Modular.get<ImageAssetProvider>()
                      .invalidateCache(key: "410.svg");
                },
                child: Text("Invalidate Cache for 410.svg"),
              ),
              GridImageView(
                items: _actualItems(),
                onTappedImage: (int index) {
                  Modular.to.pushNamed(ImageScreen.id,
                      arguments: _actualItems()[index]);
                  print("Tapped ${_actualItems()[index].imageKey}");
                },
                crossAxisCount: 5,
                imageDecorator: ImageDecorator(elevation: 4.0, radius: 8.0),
                physics: const NeverScrollableScrollPhysics(),
              )
            ],
          ),
        ));
  }
}
