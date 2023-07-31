// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:jd_mall_flutter/http/base_response.dart';
import 'package:jd_mall_flutter/http/code.dart';
import 'package:jd_mall_flutter/http/interceptors/error_interceptor.dart';
import 'package:jd_mall_flutter/http/interceptors/logs_interceptors.dart';
import 'package:jd_mall_flutter/http/interceptors/response_interceptor.dart';
import 'package:jd_mall_flutter/http/interceptors/token_Interceptor.dart';

class HttpManager {
  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORMDATA = "multipart/form-data";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";

  final Dio _dio = Dio(); // 使用默认配置

  HttpManager() {
    _dio.interceptors.add(TokenInterceptors());
    if (kDebugMode) {
      _dio.interceptors.add(LogsInterceptors());
    }
    _dio.interceptors.add(ErrorInterceptors());
    _dio.interceptors.add(ResponseInterceptors());
  }

  Future<BaseResponse> request(String url, params, Options option, bool? noTip) async {
    noTip ??= false;
    option.headers ??= HashMap();
    option.headers!['content-type'] = CONTENT_TYPE_JSON;
    option.headers!['accept'] = CONTENT_TYPE_JSON;
    option.headers!['connectTimeout'] = 30000;
    option.headers!['receiveTimeout'] = 30000;

    exceptionHandler(DioError err) {
      Response? errResponse;
      if (err.response != null) {
        errResponse = err.response;
      } else {
        errResponse = Response(statusCode: err.response?.statusCode, requestOptions: RequestOptions(path: url));
      }
      if (err.type == DioErrorType.connectionTimeout || err.type == DioErrorType.receiveTimeout) {
        errResponse!.statusCode = Code.NETWORK_TIMEOUT;
      }
      String errMsg = err.response?.toString() ?? err.error.toString();
      return BaseResponse(
        code: Code.errorHandleFunction(errResponse?.statusCode, errMsg, false),
        msg: errMsg,
        data: null,
      );
    }

    Response<BaseResponse> response;
    try {
      response = await _dio.request<BaseResponse>(url, data: params, options: option);
    } on DioError catch (e) {
      return exceptionHandler(e);
    }
    if (response.data is DioError) {
      return exceptionHandler(response.data as DioError);
    }
    return BaseResponse.fromJson(response.data?.data as Map<String, dynamic>);
  }

  ///get发起网络请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ option] 配置
  Future<BaseResponse> get(String url, {Object? params, Options? option, bool? noTip}) async {
    option ??= Options();
    option.method = "get";
    return await request(url, params, option, noTip);
  }

  ///post发起网络请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ option] 配置
  Future<BaseResponse> post(String url, {Object? params, Options? option, bool? noTip}) async {
    option ??= Options();
    option.method = "post";
    return await request(url, params, option, noTip);
  }
}

final HttpManager httpManager = HttpManager();
