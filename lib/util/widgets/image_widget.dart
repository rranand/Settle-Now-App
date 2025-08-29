import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';

Widget imageWidgetForCachedNetworkimage(
  BuildContext context,
  ImageProvider? imgProvider, {
  double borderRadius = 12,
  BoxShape boxShape = BoxShape.rectangle,
}) {
  if (imgProvider == null) {
    return CustomShimmerEffect.imageWidget(
      context,
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
  String url,
  BuildContext context, {
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
          context,
          null,
          borderRadius: borderRadius,
          boxShape: boxShape,
        ),
    errorWidget:
        (context, url, error) =>
            isLoaded
                ? imageWidgetForCachedNetworkimage(
                  context,
                  AssetImage('assets/Images/unknown.jpeg'),
                  borderRadius: borderRadius,
                  boxShape: boxShape,
                )
                : imageWidgetForCachedNetworkimage(
                  context,
                  null,
                  borderRadius: borderRadius,
                  boxShape: boxShape,
                ),
    imageBuilder:
        (context, imageProvider) =>
            isLoaded
                ? imageWidgetForCachedNetworkimage(
                  context,
                  imageProvider,
                  borderRadius: borderRadius,
                  boxShape: boxShape,
                )
                : imageWidgetForCachedNetworkimage(
                  context,
                  null,
                  borderRadius: borderRadius,
                  boxShape: boxShape,
                ),
  );
}
