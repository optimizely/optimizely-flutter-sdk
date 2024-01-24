import 'dart:io' show Platform;


class PlatformService {
  bool isAndroid() {
    return Platform.isAndroid;
  }

  bool isIOS() {
    return Platform.isIOS;
  }
  
}
