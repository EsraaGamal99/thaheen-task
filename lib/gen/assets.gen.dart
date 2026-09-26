// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsDataGen {
  const $AssetsDataGen();

  /// File path: assets/data/courses.json
  String get courses => 'assets/data/courses.json';

  /// List of all assets
  List<String> get values => [courses];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/Rectangle.png
  AssetGenImage get rectangle =>
      const AssetGenImage('assets/images/Rectangle.png');

  /// File path: assets/images/anatomy1.png
  AssetGenImage get anatomy1 =>
      const AssetGenImage('assets/images/anatomy1.png');

  /// File path: assets/images/anatomy2.jpg
  AssetGenImage get anatomy2 =>
      const AssetGenImage('assets/images/anatomy2.jpg');

  /// File path: assets/images/anatomy3.jpg
  AssetGenImage get anatomy3 =>
      const AssetGenImage('assets/images/anatomy3.jpg');

  /// File path: assets/images/anatomy4.jpeg
  AssetGenImage get anatomy4 =>
      const AssetGenImage('assets/images/anatomy4.jpeg');

  /// File path: assets/images/anatomy5.jpeg
  AssetGenImage get anatomy5 =>
      const AssetGenImage('assets/images/anatomy5.jpeg');

  /// File path: assets/images/anatomy6.jpeg
  AssetGenImage get anatomy6 =>
      const AssetGenImage('assets/images/anatomy6.jpeg');

  /// File path: assets/images/physiology1.png
  AssetGenImage get physiology1 =>
      const AssetGenImage('assets/images/physiology1.png');

  /// File path: assets/images/physiology2.png
  AssetGenImage get physiology2 =>
      const AssetGenImage('assets/images/physiology2.png');

  /// File path: assets/images/physiology3.png
  AssetGenImage get physiology3 =>
      const AssetGenImage('assets/images/physiology3.png');

  /// File path: assets/images/physiology5.jpeg
  AssetGenImage get physiology5 =>
      const AssetGenImage('assets/images/physiology5.jpeg');

  /// File path: assets/images/physiology6.jpeg
  AssetGenImage get physiology6 =>
      const AssetGenImage('assets/images/physiology6.jpeg');

  /// List of all assets
  List<AssetGenImage> get values => [
        rectangle,
        anatomy1,
        anatomy2,
        anatomy3,
        anatomy4,
        anatomy5,
        anatomy6,
        physiology1,
        physiology2,
        physiology3,
        physiology5,
        physiology6
      ];
}

class $AssetsLangGen {
  const $AssetsLangGen();

  /// File path: assets/lang/ar.json
  String get ar => 'assets/lang/ar.json';

  /// File path: assets/lang/en.json
  String get en => 'assets/lang/en.json';

  /// List of all assets
  List<String> get values => [ar, en];
}

class $AssetsVideosGen {
  const $AssetsVideosGen();

  /// File path: assets/videos/player1.mp4
  String get player1 => 'assets/videos/player1.mp4';

  /// File path: assets/videos/player2.mp4
  String get player2 => 'assets/videos/player2.mp4';

  /// File path: assets/videos/player3.mp4
  String get player3 => 'assets/videos/player3.mp4';

  /// List of all assets
  List<String> get values => [player1, player2, player3];
}

abstract final class Assets {
  static const $AssetsDataGen data = $AssetsDataGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLangGen lang = $AssetsLangGen();
  static const $AssetsVideosGen videos = $AssetsVideosGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
