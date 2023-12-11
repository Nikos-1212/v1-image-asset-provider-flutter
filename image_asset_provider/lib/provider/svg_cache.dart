library flutter_svg_provider;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

/// An [Enum] of the possible image path sources.
enum SvgSource {
  file,
  asset,
  network,
}

/// Rasterizes given svg picture for displaying in [Image] widget:
///
/// ```dart
/// Image(
///   width: 32,
///   height: 32,
///   image: Svg('assets/my_icon.svg'),
/// )
/// ```
class Svg extends ImageProvider<SvgImageKey> {
  /// Path to svg file or asset
  final String path;

  /// Source of svg image
  final SvgSource source;

  /// The name of the package from which the image is included.
  final String? package;

  /// CacheManager from which the image files are loaded.
  final BaseCacheManager? cacheManager;

  /// Set headers for the image provider, for example for authentication
  final Map<String, String>? headers;

  String get keyPath => package == null ? path : 'packages/$package/$path';

  /// Width and height can also be specified from [Image] constrictor.
  /// Default size is 100x100 logical pixels.
  /// Different size can be specified in [Image] parameters

  const Svg.asset(this.path, {this.package})
      : source = SvgSource.asset,
        cacheManager = null,
        headers = null;

  const Svg.network(this.path, {this.cacheManager, this.headers})
      : source = SvgSource.network,
        package = null;

  @override
  Future<SvgImageKey> obtainKey(ImageConfiguration configuration) {
    const Color color = Colors.transparent;
    final double scale = configuration.devicePixelRatio ?? 1.0;
    final double logicWidth = configuration.size?.width ?? 100;
    final double logicHeight = configuration.size?.height ?? 100;

    return SynchronousFuture<SvgImageKey>(
      SvgImageKey(
        path: keyPath,
        cacheManager: cacheManager ?? DefaultCacheManager(),
        headers: headers,
        scale: scale,
        color: color,
        source: source,
        pixelWidth: (logicWidth * scale).round(),
        pixelHeight: (logicHeight * scale).round(),
      ),
    );
  }

  @override
  ImageStreamCompleter load(SvgImageKey key, decode) {
    return OneFrameImageStreamCompleter(_loadAsync(key));
  }

  static Future<T> _getSvgRaw<T>(SvgImageKey key) async {
    switch (key.source) {
      case SvgSource.network:
        final Uint8List data = await _getSvgBytes(key);
        return data as T;
      case SvgSource.asset:
        final String data = await rootBundle.loadString(key.path);
        return data as T;
      case SvgSource.file:
        final String data = await File(key.path).readAsString();
        return data as T;
    }
  }

  static Future<Uint8List> _getSvgBytes(SvgImageKey key) async {
    final FileInfo? fileInfo =
        await key.cacheManager.getFileFromCache(key.path);
    if (fileInfo != null && fileInfo.file.existsSync()) {
      return await fileInfo.file.readAsBytes();
    } else {
      final http.Response response =
          await http.get(Uri.parse(key.path), headers: key.headers);
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        await key.cacheManager.putFile(key.path, bytes);
        return bytes;
      } else {
        cacheLogger.log(
            'Svg: Failed to download file from ${key.path} with error:\n Invalid statusCode: ${response.statusCode}, uri = ${key.path}',
            CacheManagerLogLevel.debug);
        throw HttpException(
            "Invalid statusCode: ${response.statusCode}, uri = ${key.path}");
      }
    }
  }

  static Future<ImageInfo> _loadAsync(SvgImageKey key) async {
    String svgString = key.source == SvgSource.network
        ? String.fromCharCodes(await _getSvgRaw<Uint8List>(key))
        : await _getSvgRaw<String>(key);

    final pictureInfo = await vg.loadPicture(
      SvgStringLoader(svgString),
      null,
      clipViewbox: false,
    );

    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    canvas.scale(key.pixelWidth / pictureInfo.size.width,
        key.pixelHeight / pictureInfo.size.height);
    canvas.drawPicture(pictureInfo.picture);

    final Picture scaledPicture = recorder.endRecording();
    final ui.Image image =
        await scaledPicture.toImage(key.pixelWidth, key.pixelHeight);

    return ImageInfo(
      image: image,
      scale: 1,
    );
  }

  // Note: == and hashCode not overrided as changes in properties
  // (width, height and scale) are not observable from the here.
  // [SvgImageKey] instances will be compared instead.
  @override
  String toString() => '$runtimeType(${describeIdentity(keyPath)})';

  // Running on web with Colors.transparent may throws the exception `Expected a value of type 'SkDeletable', but got one of type 'Null'`.
  static Color getFilterColor(color) {
    if (kIsWeb && color == Colors.transparent) {
      return const Color(0x01ffffff);
    } else {
      return color ?? Colors.transparent;
    }
  }
}

@immutable
class SvgImageKey {
  const SvgImageKey({
    required this.path,
    required this.cacheManager,
    required this.headers,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.scale,
    required this.source,
    this.color,
  });

  /// Path to svg asset.
  final String path;

  /// Width in physical pixels.
  /// Used when raterizing.
  final int pixelWidth;

  /// Height in physical pixels.
  /// Used when raterizing.
  final int pixelHeight;

  /// Color to tint the SVG
  final Color? color;

  /// Image source.
  final SvgSource source;

  /// Used to calculate logical size from physical, i.e.
  /// logicalWidth = [pixelWidth] / [scale],
  /// logicalHeight = [pixelHeight] / [scale].
  /// Should be equal to [MediaQueryData.devicePixelRatio].
  final double scale;

  final BaseCacheManager cacheManager;

  final Map<String, String>? headers;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SvgImageKey &&
        other.path == path &&
        other.pixelWidth == pixelWidth &&
        other.pixelHeight == pixelHeight &&
        other.scale == scale &&
        other.source == source &&
        other.cacheManager == cacheManager &&
        other.headers == headers;
  }

  @override
  int get hashCode =>
      Object.hash(path, pixelWidth, pixelHeight, scale, source, cacheManager);

  @override
  String toString() => '${objectRuntimeType(this, 'SvgImageKey')}'
      '(path: "$path", pixelWidth: $pixelWidth, pixelHeight: $pixelHeight, scale: $scale, source: $source, cacheManager: $cacheManager, headers: $headers)';
}
