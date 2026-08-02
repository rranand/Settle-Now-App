import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

Widget imageWidgetWithShimmerEffect(
  ImageProvider? imgProvider,
  bool isLast,
  BuildContext context,
) {
  if (imgProvider == null) {
    return CustomShimmerEffect.imageWidget(context, shape: BoxShape.circle);
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

int convertInitialToNumber(String input) {
  if (input.isEmpty) {
    return Random().nextInt(UiConstant.colorsWithShade100.length);
  }
  int c1 = input.codeUnitAt(0);
  int c2 = input.length > 1 ? input.codeUnitAt(1) : 0;
  return (c1 << 16) | c2;
}

Widget errorImageWidget(BaseUserModel user, double radius, bool isLast) {
  String nameInitial = "";
  final List<String> nameArr = user.name.trim().split(" ");
  switch (nameArr.length) {
    case 0:
      nameInitial = "UA";
      break;
    case 1:
      {
        if (user.name.trim().isNotEmpty) {
          nameInitial = user.name[0];
        }
      }
      break;
    default:
      nameInitial = nameArr.first[0] + nameArr.last[0];
  }
  nameInitial = nameInitial.toUpperCase();
  int colourIndex =
      convertInitialToNumber(nameInitial) %
      UiConstant.colorsWithShade100.length;

  return Container(
    width: radius,
    height: radius,
    decoration: BoxDecoration(shape: BoxShape.circle),
    child: colouredWidget(
      Text(
        nameInitial,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.5,
          color: UiConstant.colors[colourIndex],
        ),
      ),
      UiConstant.colorsWithShade100[colourIndex],
    ),
  );
}

Widget eachUserImageBuilder(
  BaseUserModel eachUser,
  int index,
  bool isLast, {
  double nextImageOffset = 22,
  double imageRadius = 30,
}) {
  Widget profileImage = errorImageWidget(eachUser, imageRadius, isLast);

  if (eachUser.profilePic.isNotEmpty) {
    profileImage = CachedNetworkImage(
      imageUrl: eachUser.profilePic,
      width: imageRadius,
      height: imageRadius,
      progressIndicatorBuilder:
          (context, url, downloadProgress) =>
              imageWidgetWithShimmerEffect(null, isLast, context),
      errorWidget:
          (context, url, error) =>
              errorImageWidget(eachUser, imageRadius, isLast),
      imageBuilder:
          (context, imageProvider) =>
              imageWidgetWithShimmerEffect(imageProvider, isLast, context),
    );
  }

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
  List<BaseUserModel> users,
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
