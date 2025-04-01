import 'package:flutter/material.dart';

double getScreenHeightWithoutAppBar(BuildContext context) {
  return MediaQuery.of(context).size.height -
      AppBar().preferredSize.height -
      MediaQuery.of(context).padding.top;
}
