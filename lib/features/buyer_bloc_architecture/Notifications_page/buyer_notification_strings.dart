/// Static UI strings for the Buyer Notification Center, localized in English
/// and Tamil. Language selection is driven by [languageCode] ('en' or 'ta').
class BuyerNotificationStrings {
  const BuyerNotificationStrings({this.languageCode = 'en'});

  final String languageCode;

  bool get isTamil => languageCode == 'ta';

  String get pageTitle => isTamil ? 'அறிவிப்புகள்' : 'Notifications';
  String get markAllRead => isTamil ? 'அனைத்தும் படிக்கப்பட்டது' : 'Mark all read';
  String get clearAll => isTamil ? 'அனைத்தையும் அழி' : 'Clear all';
  String get searchHint => isTamil ? 'தலைப்பு அல்லது ஆர்டர் ஐடியில் தேடுங்கள்…' : 'Search by title, order ID or restaurant…';
  String get emptyTitle => isTamil ? 'அறிவிப்புகள் இல்லை' : 'No notifications yet';
  String get emptySubtitle => isTamil ? 'புதிய ஆர்டர், சலுகைகள் மற்றும் செய்திகள் இங்கே தோன்றும்.' : 'Your order updates, offers and messages will appear here.';
  String get retry => isTamil ? 'மீண்டும் முயற்சிக்கவும்' : 'Retry';
  String get undo => isTamil ? 'மீள்' : 'Undo';
  String get notificationDeleted => isTamil ? 'அறிவிப்பு நீக்கப்பட்டது' : 'Notification deleted';
  String get allCleared => isTamil ? 'அனைத்து அறிவிப்புகளும் நீக்கப்பட்டன' : 'All notifications cleared';
  String get markedAllRead => isTamil ? 'அனைத்தும் படிக்கப்பட்டன' : 'All notifications marked as read';

  String get filterAll => isTamil ? 'அனைத்தும்' : 'All';
  String get filterOrders => isTamil ? 'ஆர்டர்கள்' : 'Orders';
  String get filterPayments => isTamil ? 'பணம்' : 'Payments';
  String get filterOffers => isTamil ? 'சலுகைகள்' : 'Offers';
  String get filterChats => isTamil ? 'செய்திகள்' : 'Chats';
  String get filterAlerts => isTamil ? 'எச்சரிக்கை' : 'Alerts';

  String get actionTrackOrder => isTamil ? 'ஆர்டரை கண்காணி' : 'Track Order';
  String get actionViewOrder => isTamil ? 'ஆர்டரை பார்' : 'View Order';
  String get actionReply => isTamil ? 'பதிலளி' : 'Reply';
  String get actionViewReceipt => isTamil ? 'ரசீது பார்' : 'View Receipt';
  String get actionApplyCoupon => isTamil ? 'கூப்பன் பயன்படுத்து' : 'Apply Coupon';
  String get actionOpenWallet => isTamil ? 'வாலட் திற' : 'Open Wallet';
  String get actionRateNow => isTamil ? 'மதிப்பிடு' : 'Rate Now';
  String get actionViewDetails => isTamil ? 'விவரம் பார்' : 'View Details';

  /// Returns the label for a given [BuyerNotificationCategory] filter.
  String filterLabel(String filterKey) {
    switch (filterKey) {
      case 'orders':
        return filterOrders;
      case 'payments':
        return filterPayments;
      case 'offers':
        return filterOffers;
      case 'chats':
        return filterChats;
      case 'alerts':
        return filterAlerts;
      default:
        return filterAll;
    }
  }
}
