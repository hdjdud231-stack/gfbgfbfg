/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/amazon_prime_video_logo.png
  AssetGenImage get amazonPrimeVideoLogo =>
      const AssetGenImage('assets/images/amazon_prime_video_logo.png');

  /// File path: assets/images/app_icon.png
  AssetGenImage get appIcon =>
      const AssetGenImage('assets/images/app_icon.png');

  /// File path: assets/images/app_icon_108.png
  AssetGenImage get appIcon108 =>
      const AssetGenImage('assets/images/app_icon_108.png');

  /// File path: assets/images/app_logo.png
  AssetGenImage get appLogo =>
      const AssetGenImage('assets/images/app_logo.png');

  /// File path: assets/images/apple_tv_logo.png
  AssetGenImage get appleTvLogo =>
      const AssetGenImage('assets/images/apple_tv_logo.png');

  /// File path: assets/images/disney_plus_logo.png
  AssetGenImage get disneyPlusLogo =>
      const AssetGenImage('assets/images/disney_plus_logo.png');

  /// File path: assets/images/hulu_logo.png
  AssetGenImage get huluLogo =>
      const AssetGenImage('assets/images/hulu_logo.png');

  /// File path: assets/images/netflix_logo.png
  AssetGenImage get netflixLogo =>
      const AssetGenImage('assets/images/netflix_logo.png');

  /// File path: assets/images/subtitles_poster.jpg
  AssetGenImage get subtitlesPoster =>
      const AssetGenImage('assets/images/subtitles_poster.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [
        amazonPrimeVideoLogo,
        appIcon,
        appIcon108,
        appLogo,
        appleTvLogo,
        disneyPlusLogo,
        huluLogo,
        netflixLogo,
        subtitlesPoster
      ];
}

class $AssetsLottieGen {
  const $AssetsLottieGen();

  /// File path: assets/lottie/watching_tv.json
  String get watchingTv => 'assets/lottie/watching_tv.json';

  /// List of all assets
  List<String> get values => [watchingTv];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLottieGen lottie = $AssetsLottieGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

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
