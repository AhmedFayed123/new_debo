import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'myimage.dart';

// ignore: must_be_immutable
class MyNetworkImage extends StatelessWidget {
  String imageUrl;
  double? height, width;
  dynamic fit;

  MyNetworkImage(
      {super.key,
      required this.imageUrl,
      required this.fit,
      this.height,
      this.width});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.contains('no_img')) {
      return MyImage(
        width: width,
        height: height,
        imagePath: "no_image_land.png",
        fit: BoxFit.cover,
      );
    }
    return SizedBox(
      height: height,
      width: width,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        // cacheKey: imageUrl,
        // cacheManager: CacheManager(
        //   Config(
        //     imageUrl,
        //     stalePeriod: const Duration(days: 7),
        //     maxNrOfCacheObjects: 100,
        //   ),
        // ),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
        placeholder: (context, url) {
          return MyImage(
            width: width,
            height: height,
            imagePath: imageUrl.contains('land_')
                ? "no_image_land.png"
                : "no_image_port.png",
            fit: BoxFit.cover,
          );
        },
        errorWidget: (context, url, error) {
          return MyImage(
            width: width,
            height: height,
            imagePath: imageUrl.contains('land_')
                ? "no_image_land.png"
                : "no_image_port.png",
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
