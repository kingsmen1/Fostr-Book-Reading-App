import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';

/// Global widget that depicts a custom rounded user icon
/// Use for creating user profile images
class RoundedImage extends StatelessWidget {
  final String? url;
  final String path;
  final double width;
  final double height;
  final EdgeInsets? margin;
  final double borderRadius;
  final BoxShape shape;

  const RoundedImage({
    Key? key,
    this.url,
    this.path = IMAGES + "profile.png",
    this.margin,
    this.width = 40,
    this.height = 40,
    this.borderRadius = 40,
    this.shape = BoxShape.circle,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: (shape == BoxShape.circle)
            ? null
            : BorderRadius.circular(borderRadius),
        image: DecorationImage(
          image: (url == null || url == "" || url == "null")
              ? Image.asset(path).image
              : FosterImageProvider(imageUrl: url!, cachedKey: url!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
