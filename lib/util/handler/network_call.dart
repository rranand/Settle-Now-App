import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';

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

Future<Response> createAPICall(
  String url,
  String methodName,
  String token,
  dynamic jsonData,
) async {
  Response newRes = Response(
    jsonEncode({
      "status": false,
      "Message": Crypto.encrypt("Something went wrong!"),
    }),
    422,
  );
  Function httpType = getHttpMethod(methodName);
  try {
    String host = "https://prod-api.settlenow.in/";
    if (kDebugMode) {
      host = "http://192.168.1.35:9008/";
    }
    String tokenization = Crypto.createJSONDataTOJWT(jsonData);
    Map<String, String> headersMap = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
      'Access-Control-Allow-Origin': host,
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
      String jsonJWTData = jsonDecode(res.body)['data'];
      String responseBody = Crypto.extractJSONfromJWT(jsonJWTData);
      newRes = Response(responseBody, res.statusCode);
    }

    return newRes;
  } catch (_) {
    throw "Something went wrong";
  }
}
