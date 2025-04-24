import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';

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

Widget eachUserImageBuilder(
  UserModel eachUser,
  int index,
  bool isLast, {
  double nextImageOffset = 22,
  double imageRadius = 30,
}) {
  Widget profileImage = CachedNetworkImage(
    imageUrl: eachUser.profileImage.isEmpty ? "" : eachUser.profileImage,
    width: imageRadius,
    height: imageRadius,
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
      left: index * nextImageOffset,
      child: profileImage,
    );
  }
  return profileImage;
}

Widget overlapUserImageWidget(
  BuildContext context,
  List<UserModel> users,
  int maxProfileImageToShow, {
  int? totalUsers,
  double nextImageOffset = 22,
  double imageRadius = 30,
}) {
  if (users.isEmpty) {
    return SizedBox();
  }
  totalUsers ??= users.length;

  bool isUserMoreThan = totalUsers > maxProfileImageToShow;
  int imagesToShow = min(users.length, maxProfileImageToShow);
  List<Widget> allUsersImage = List.generate(
    imagesToShow,
    (index) => eachUserImageBuilder(
      users[index],
      index,
      (index == maxProfileImageToShow - 1) && isUserMoreThan,
      imageRadius: imageRadius,
      nextImageOffset: nextImageOffset,
    ),
  );

  if (isUserMoreThan) {
    allUsersImage.add(
      Positioned(
        left: (allUsersImage.length - 1) * nextImageOffset,
        child: Container(
          width: imageRadius,
          height: imageRadius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(
            child: Text(
              "+${totalUsers - imagesToShow}",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  return SizedBox(
    width:
        imagesToShow * imageRadius +
        (imagesToShow - 1) * (nextImageOffset - imageRadius),
    height: imageRadius,
    child: Stack(alignment: Alignment.topLeft, children: allUsersImage),
  );
}
