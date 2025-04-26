import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

Widget imageWidgetForCachedNetworkimage(
  ImageProvider? imgProvider,
  bool isLast,
) {
  if (imgProvider == null) {
    return CustomShimmerEffect.imageWidget(shape: BoxShape.circle);
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

Widget errorImageWidget(UserModel user, bool isLast) {
  String nameInitial = "";
  final List<String> nameArr = user.name.split(" ");

  switch (nameArr.length) {
    case 0:
      nameInitial = "UA";
      break;
    case 1:
      nameInitial = user.name.substring(0, min(user.name.length, 2));
      break;
    default:
      nameInitial = nameArr.first[0] + nameArr.last[0];
  }

  nameInitial = nameInitial.toUpperCase();
  int colourIndex = Random().nextInt(UiConstant.colorsWithShade100.length);

  return Container(
    decoration: BoxDecoration(shape: BoxShape.circle),
    child: colouredIcon(
      Text(
        nameInitial,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: UiConstant.colors[colourIndex],
        ),
      ),
      UiConstant.colorsWithShade100[colourIndex],
    ),
  );
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
            imageWidgetForCachedNetworkimage(null, isLast),
    errorWidget: (context, url, error) => errorImageWidget(eachUser, isLast),
    imageBuilder:
        (context, imageProvider) =>
            imageWidgetForCachedNetworkimage(imageProvider, isLast),
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
