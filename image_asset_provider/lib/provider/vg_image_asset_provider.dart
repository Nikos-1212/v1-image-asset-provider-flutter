import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:framework_contracts_flutter/framework_contracts_flutter.dart';
import 'package:image_asset_provider/provider/svg_cache.dart';
import 'package:path/path.dart' as path;

import '../gen/assets.gen.dart';

class VGImageAssetProvider extends ImageAssetProvider {
  final _packageName = "image_asset_provider";
  late ResourceConfig _config;
  final _cacheManager = DefaultCacheManager();

  static final VGImageAssetProvider _instance = VGImageAssetProvider._();

  VGImageAssetProvider._() {
    if (kDebugMode) {
      CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
    }
  }

  static VGImageAssetProvider get instance => _instance;

  @override
  Future<void> initConfig(ResourceConfig config, {Function? callback}) async {
    _config = config;
  }

  @override
  void invalidateCache({String? key}) {
    if (key != null) {
      _cacheManager.removeFile(_getUrl(key));
    } else {
      _cacheManager.emptyCache();
    }
  }

  @override
  ImageProvider getPlaceholder({String? key}) {
    var imageProvider = AssetImage(key ?? Assets.images.placeholder.keyName,
        package: _packageName);
    return imageProvider;
  }

  @override
  Future<ImageProvider<Object>?> getImage(String key,
      {String? errorPlaceholder, bool forceUpdateCache = false}) async {
    return await _getAsset(key,
        errorPlaceholder: errorPlaceholder,
        forceUpdateCache: forceUpdateCache,
        forAsset: false);
  }

  Future<ImageProvider?> _getAsset(String key,
      {String? errorPlaceholder,
      required bool forceUpdateCache,
      required bool forAsset}) async {
    var extension = path.extension(key).toLowerCase();
    if (extension == ".svg") {
      return await _getAssetSVG(key,
          errorPlaceholder: errorPlaceholder,
          forceUpdateCache: forceUpdateCache,
          forAsset: forAsset);
    } else {
      return await _getAssetImage(key,
          errorPlaceholder: errorPlaceholder,
          forceUpdateCache: forceUpdateCache,
          forAsset: forAsset);
    }
  }

  Future<ImageProvider?> _getAssetImage(String key,
      {String? errorPlaceholder,
      required bool forceUpdateCache,
      required bool forAsset}) async {
    var imageProvider = AssetImage(key, package: _packageName);

    final completer = _setupImageStreamCompleter(imageProvider);
    try {
      return await completer.future;
    } catch (error) {
      if (forAsset) {
        return null;
      }
      return await _getNetworkImage(key,
          errorPlaceholder: errorPlaceholder,
          forceUpdateCache: forceUpdateCache);
    }
  }

  Future<ImageProvider?> _getAssetSVG(String key,
      {String? errorPlaceholder,
      required bool forceUpdateCache,
      required bool forAsset}) async {
    var imageProvider = Svg.asset(key, package: _packageName);

    final completer = _setupImageStreamCompleter(imageProvider);
    try {
      return await completer.future;
    } catch (error) {
      if (forAsset) {
        return null;
      }
      return await _getNetworkSvg(key,
          errorPlaceholder: errorPlaceholder,
          forceUpdateCache: forceUpdateCache);
    }
  }

  Future<ImageProvider?> _getNetworkImage(String key,
      {String? errorPlaceholder, required bool forceUpdateCache}) async {
    var url = _getUrl(key);
    var headers = _getHeaders();

    if (forceUpdateCache) {
      invalidateCache(key: key);
    }
    var imageProvider = CachedNetworkImageProvider(url,
        cacheManager: _cacheManager, headers: headers);

    final completer = _setupImageStreamCompleter(imageProvider);

    try {
      return await completer.future;
    } catch (error) {
      return errorPlaceholder != null
          ? await _getAsset(errorPlaceholder,
              forceUpdateCache: false, forAsset: true)
          : null;
    }
  }

  Future<ImageProvider?> _getNetworkSvg(String key,
      {String? errorPlaceholder, required bool forceUpdateCache}) async {
    var url = _getUrl(key);
    var headers = _getHeaders();

    if (forceUpdateCache) {
      invalidateCache(key: key);
    }
    var imageProvider =
        Svg.network(url, cacheManager: _cacheManager, headers: headers);

    final completer = _setupImageStreamCompleter(imageProvider);

    try {
      return await completer.future;
    } catch (error) {
      return errorPlaceholder != null
          ? await _getAsset(errorPlaceholder,
              forceUpdateCache: false, forAsset: true)
          : null;
    }
  }

  String _getUrl(String key) {
    //This will require modification at a later stage.
    var extension = path.extension(key).toLowerCase();
    return extension == ".svg"
        ? "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/$key"
        : "https://api.slingacademy.com/public/sample-photos/$key";
  }

  Map<String, String> _getHeaders() {
    var headers = <String, String>{};
    debugPrint(_config.getTenant());
    // headers["Authorization"] =
    //     "Bearer dUpUdnlObWM5Zk9mSDlOVENhS1lqT0REeVJ3YTpWWE05Z1pVbGJRbDJSWkl3cE5zWEFGUm1oZVVh";
    // headers["locale"] = _config.getLocale();
    // headers["User-Agent"] =
    //     "VitalityActive/1.4.2.35087/1.2.0.000 (sdk_gphone64_arm64; Android 12)";
    // headers["Content-Type"] = "application/json";
    return headers;
  }

  Completer<ImageProvider> _setupImageStreamCompleter(
      ImageProvider imageProvider) {
    final streamCompleter = imageProvider.resolve(ImageConfiguration.empty);

    final completer = Completer<ImageProvider>();

    final listener = ImageStreamListener((_, __) {
      completer.complete(imageProvider);
    }, onError: (_, __) {
      completer.completeError('Image not found');
    });

    streamCompleter.addListener(listener);

    return completer;
  }
}
