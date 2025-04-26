import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';

Widget imageWidgetForCachedNetworkimage(
  ImageProvider? imgProvider, {
  double borderRadius = 12,
  BoxShape boxShape = BoxShape.rectangle,
}) {
  if (imgProvider == null) {
    return CustomShimmerEffect.imageWidget(
      radius: borderRadius,
      shape: boxShape,
    );
  } else {
    return Container(
      decoration: BoxDecoration(
        shape: boxShape,
        borderRadius:
            boxShape == BoxShape.rectangle
                ? BorderRadius.circular(borderRadius)
                : null,
        image: DecorationImage(image: imgProvider, fit: BoxFit.fill),
      ),
    );
  }
}

Widget imageWidgetForCachedNetworkImage(
  String url, {
  double borderRadius = 12,
  bool isLoaded = true,
  Alignment alignment = Alignment.center,
  double? width,
  double? height,
  BoxShape boxShape = BoxShape.rectangle,
}) {
  return CachedNetworkImage(
    imageUrl: url,
    alignment: alignment,
    width: width,
    height: height,
    progressIndicatorBuilder:
        (context, url, downloadProgress) => imageWidgetForCachedNetworkimage(
          null,
          borderRadius: borderRadius,
          boxShape: boxShape,
        ),
    errorWidget:
        (context, url, error) =>
            isLoaded
                ? imageWidgetForCachedNetworkimage(
                  AssetImage('assets/Images/unknown.jpeg'),
                  borderRadius: borderRadius,
                  boxShape: boxShape,
                )
                : imageWidgetForCachedNetworkimage(
                  null,
                  borderRadius: borderRadius,
                  boxShape: boxShape,
                ),
    imageBuilder:
        (context, imageProvider) =>
            isLoaded
                ? imageWidgetForCachedNetworkimage(
                  imageProvider,
                  borderRadius: borderRadius,
                  boxShape: boxShape,
                )
                : imageWidgetForCachedNetworkimage(
                  null,
                  borderRadius: borderRadius,
                  boxShape: boxShape,
                ),
  );
}
