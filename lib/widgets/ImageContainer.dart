import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FosterImage extends CachedNetworkImage {
  FosterImage(
      {Key? key,
      required String imageUrl,
      String? cachedKey,
      double? height,
      double? width,
      BoxFit? fit})
      : super(
            // memCacheWidth: 300,
            // memCacheHeight:300,
            key: key,
            imageUrl: imageUrl,
            cacheKey: cachedKey,
            fit: fit ?? BoxFit.contain,
            height: height,
            width: width);
}

class FosterImageProvider extends CachedNetworkImageProvider {
  final String imageUrl;
  FosterImageProvider({Key? key, required this.imageUrl, String? cachedKey})
      : super(imageUrl, cacheKey: cachedKey);
}
