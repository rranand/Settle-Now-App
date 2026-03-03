import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:settlenow/model/api_response_model.dart';
import 'package:settlenow/util/handler/crypto.dart';

final ApiResponseModel newRes = ApiResponseModel(
  body: "{\"message\": \"Something went wrong!\"}",
  statusCode: 422,
);

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

Future<ApiResponseModel> createAPICall(
  String url,
  String methodName,
  String token,
  dynamic jsonData,
) async {
  Function httpType = getHttpMethod(methodName);
  try {
    String host = "https://prod-api.settlenow.in/";
    if (kDebugMode) {
      host = "http://192.168.1.12:9008/";
    }
    String tokenization = Crypto.createJSONDataTOJWT(jsonData);
    Map<String, String> headersMap = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
    };

    Response res = await (methodName.contains("get")
            ? httpType(Uri.parse(host + url), headers: headersMap)
            : httpType(
              Uri.parse(host + url),
              headers: headersMap,
              body: jsonEncode({"data": tokenization}),
            ))
        .timeout(Duration(seconds: 20));

    var resData = jsonDecode(res.body);

    if (resData['data'] != null) {
      String jsonJWTData = resData['data'];
      String responseBody = Crypto.extractJSONfromJWT(jsonJWTData);

      return ApiResponseModel(body: responseBody, statusCode: res.statusCode);
    }

    return newRes;
  } catch (e) {
    throw "Something went wrong";
  }
}
