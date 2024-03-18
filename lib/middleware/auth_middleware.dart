import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_mall_flutter/common/util/util.dart';
import 'package:jd_mall_flutter/routes.dart';

class EnsureAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return isLogin() ? null : RouteSettings(name: RoutesEnum.loginPage.path, arguments: {"from": route});
  }
}
