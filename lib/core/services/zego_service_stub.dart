class ZegoUIKitPrebuiltCallInvitationService {
  ZegoUIKitPrebuiltCallInvitationService._internal();

  static final ZegoUIKitPrebuiltCallInvitationService _instance =
      ZegoUIKitPrebuiltCallInvitationService._internal();

  factory ZegoUIKitPrebuiltCallInvitationService() => _instance;

  Future<void> init({
    required int appID,
    required String userID,
    required String userName,
    required List<dynamic> plugins,
    String appSign = '',
    String token = '',
    dynamic requireConfig,
    dynamic events,
    dynamic config,
    dynamic ringtoneConfig,
    dynamic uiConfig,
    dynamic notificationConfig,
    dynamic innerText,
    dynamic invitationEvents,
  }) async {}

  Future<void> uninit() async {}
}
