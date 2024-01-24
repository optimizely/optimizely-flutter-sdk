import 'package:optimizely_flutter_sdk/src/utils/platform_service.dart';

class MocAndroidPlatformService extends PlatformService {
  @override
  bool isAndroid() {
    return true;
  }
  @override
  bool isIOS() {
    return false;
  }
}

class MociOSPlatformService extends PlatformService {
  @override
  bool isAndroid() {
    return false;
  }
  @override
  bool isIOS() {
    return true;
  }
}

class MocNotSupportedPlatformService extends PlatformService {
  @override
  bool isAndroid() {
    return false;
  }
  @override
  bool isIOS() {
    return false;
  }
}