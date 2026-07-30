import 'dart:async';

abstract class DeliveryOnboardingServiceBase {
  Stream<double> uploadVideoChunked(String filePath, {int chunkSize = 1024 * 512});
  Future<bool> checkNetworkConnectivity();
}

class DeliveryOnboardingService implements DeliveryOnboardingServiceBase {
  @override
  Future<bool> checkNetworkConnectivity() async {
    return true;
  }

  @override
  Stream<double> uploadVideoChunked(String filePath, {int chunkSize = 1024 * 512}) async* {
    final totalChunks = 5;
    for (int i = 1; i <= totalChunks; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      yield i / totalChunks;
    }
  }
}
