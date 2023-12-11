import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:framework_contracts_flutter/framework_contracts_flutter.dart';
import 'package:image_asset_provider/image_asset_provider.dart';
import 'package:test_app/screen/image_screen.dart';

import 'screen/home_screen.dart';

void main() {
  runApp(ModularApp(module: MyModule(), child: MyApp()));
}

class MyModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.singleton<ImageAssetProvider>((i) => VGImageAssetProvider.instance)
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(Modular.initialRoute,
            child: (_, args) => const HomeScreen()),
        ChildRoute(ImageScreen.id,
            child: (_, args) => ImageScreen(
                  imageItem: args.data,
                ))
      ];
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Modular.get<ImageAssetProvider>().initConfig(ResourceConfig(tenant: "9998", locale: "en_US", groupId: "44896"));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
      builder: (context) => PlatformApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Base Project',
          builder: (context, child) => Stack(
                alignment: Alignment.center,
                children: [child!],
              ),
          routerDelegate: Modular.routerDelegate,
          routeInformationParser: Modular.routeInformationParser,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ]),
    );
  }
}
