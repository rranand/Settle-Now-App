import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';

const double _nextImageOffset = 22;
const double _imageRadius = 30;

Widget profileimageWidgetForCachedNetworkimage(
  ImageProvider? imgProvider,
  bool isLast,
) {
  if (imgProvider == null) {
    return CustomShimmerEffect.cachedNetworkImageWidget(shape: BoxShape.circle);
  } else {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imgProvider,
          fit: BoxFit.fill,
          colorFilter:
              isLast
                  ? ColorFilter.mode(
                    Colors.black.withAlpha(153),
                    BlendMode.darken,
                  )
                  : null,
        ),
      ),
    );
  }
}

Widget eachUserImageBuilder(String eachUser, int index, bool isLast) {
  Widget profileImage = CachedNetworkImage(
    imageUrl: eachUser.isEmpty ? "" : eachUser,
    width: _imageRadius,
    height: _imageRadius,
    progressIndicatorBuilder:
        (context, url, downloadProgress) =>
            profileimageWidgetForCachedNetworkimage(null, isLast),
    errorWidget:
        (context, url, error) => profileimageWidgetForCachedNetworkimage(
          AssetImage("assets/Images/unknown.jpeg"),
          isLast,
        ),
    imageBuilder:
        (context, imageProvider) =>
            profileimageWidgetForCachedNetworkimage(imageProvider, isLast),
  );
  if (index > 0) {
    profileImage = Positioned(
      left: index * _nextImageOffset,
      child: profileImage,
    );
  }
  return profileImage;
}

Widget overlapUserImageWidget(
  BuildContext context,
  List<String> users,
  int maxProfileImageToShow, {
  int? totalUsers,
}) {
  if (users.isEmpty) {
    return SizedBox();
  }
  totalUsers ??= users.length;

  bool isUserMoreThan = totalUsers > maxProfileImageToShow;
  List<Widget> allUsersImage = List.generate(
    min(users.length, maxProfileImageToShow),
    (index) => eachUserImageBuilder(
      users[index],
      index,
      (index == maxProfileImageToShow - 1) && isUserMoreThan,
    ),
  );

  if (isUserMoreThan) {
    allUsersImage.add(
      Positioned(
        left: (allUsersImage.length - 1) * _nextImageOffset,
        child: Container(
          width: _imageRadius,
          height: _imageRadius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(
            child: Text(
              "+${totalUsers - min(users.length, maxProfileImageToShow)}",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: _imageRadius,
    child: Stack(alignment: Alignment.topLeft, children: allUsersImage),
  );
}
