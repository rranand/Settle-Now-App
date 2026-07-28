import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

final Set<String> publicURL = {
  "get server",
  "post auth/signup/google",
  "post auth/signup",
  "post auth/otp",
  "patch auth/otp",
  "post auth/googleLogin",
  "post auth/refresh",
};

Function getHttpMethod(String methodName) {
  switch (methodName.toLowerCase()) {
    case "get":
      return get;
    case "post":
      return post;
    case "patch":
      return patch;
    case "put":
      return put;
    default:
      return delete;
  }
}

bool isPublicURL(String url) {
  return publicURL.contains(url);
}

Future<ApiResponseModel> createAPICall(
  String url,
  String methodName,
  dynamic jsonData,
) async {
  if (kDebugMode) {
    logDebug("${"-" * 30}\nRequested URL: $url\nMethod: $methodName");
  }

  Function httpType = getHttpMethod(methodName);
  try {
    String host = "https://prod-api.settlenow.in/";
    if (kDebugMode) {
      host = "http://192.168.1.4:9008/";
    }

    String? accessToken;

    if (!isPublicURL("${methodName.toLowerCase()} $url")) {
      accessToken = await SessionManager.instance.getValidAccessToken();

      if (accessToken == null) {
        throw ApiConstant.sessionExpired;
      }
    }

    Map<String, String> headersMap = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      ...SessionManager.instance.authHeaders,
      ...(accessToken != null && accessToken.isNotEmpty
          ? {'Authorization': 'Bearer $accessToken'}
          : {}),
    };

    Response res = await (methodName.contains("get")
            ? httpType(Uri.parse(host + url), headers: headersMap)
            : httpType(
              Uri.parse(host + url),
              headers: headersMap,
              body: jsonData is String ? jsonData : jsonEncode(jsonData),
            ))
        .timeout(Duration(seconds: 20));

    // if (kDebugMode) {
    //   logDebug(
    //     "${"-" * 30}\nURL: $url\nMethod: $methodName\nHeader: $headersMap\nBody: $jsonData\nStatusCode: ${res.statusCode}\nResponseBody: ${res.body}",
    //   );
    // }

    return ApiResponseModel(body: res.body, statusCode: res.statusCode);
  } on TimeoutException catch (_) {
    throw "The request timed out. Please check your internet connection and try again.";
  } on SocketException catch (_) {
    throw "Unable to connect. Please check your internet connection and try again.";
  } on ClientException catch (_) {
    throw "Unable to connect to the server. Please try again.";
  } on FormatException catch (_) {
    throw "Received an invalid response from the server.";
  } catch (e) {
    if (e.toString() == ApiConstant.sessionExpired) {
      rethrow;
    }

    throw "Something went wrong. Please try again.";
  }
}
