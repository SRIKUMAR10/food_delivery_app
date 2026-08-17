import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  tamil,
}

class AppLocalizations {
  static final ValueNotifier<AppLanguage> currentLanguage =
      ValueNotifier<AppLanguage>(AppLanguage.english);

  static void setLanguage(AppLanguage language) {
    currentLanguage.value = language;
  }

  static void toggleLanguage() {
    currentLanguage.value = currentLanguage.value == AppLanguage.english
        ? AppLanguage.tamil
        : AppLanguage.english;
  }

  static bool isTamil(BuildContext context) {
    return currentLanguage.value == AppLanguage.tamil ||
        Localizations.localeOf(context).languageCode == 'ta';
  }

  static String tr(
    BuildContext context, {
    required String en,
    required String ta,
  }) {
    return isTamil(context) ? ta : en;
  }

  // --- Common Translations ---
  static String live(BuildContext context) =>
      tr(context, en: 'LIVE', ta: 'நேரலை');

  static String realTime(BuildContext context) =>
      tr(context, en: 'Real-Time Sync', ta: 'நேரடி ஒத்திசைவு');

  static String search(BuildContext context) =>
      tr(context, en: 'Search...', ta: 'தேடுக...');

  static String cancel(BuildContext context) =>
      tr(context, en: 'Cancel', ta: 'ரத்து செய்');

  static String save(BuildContext context) =>
      tr(context, en: 'Save', ta: 'சேமிக்க');

  static String update(BuildContext context) =>
      tr(context, en: 'Update', ta: 'மாற்றுக');

  static String refresh(BuildContext context) =>
      tr(context, en: 'Refresh', ta: 'புதுப்பிக்க');

  // --- Seller Dashboard Translations ---
  static String dashboard(BuildContext context) =>
      tr(context, en: 'Seller Dashboard', ta: 'விற்பனையாளர் முகப்பு');

  static String todaysRevenue(BuildContext context) =>
      tr(context, en: "Today's Revenue", ta: 'இன்றைய வருவாய்');

  static String pendingOrders(BuildContext context) =>
      tr(context, en: 'Pending Orders', ta: 'நிலுவை ஆர்டர்கள்');

  static String lowStockAlerts(BuildContext context) =>
      tr(context, en: 'Low Stock Alerts', ta: 'குறைந்த இருப்பு எச்சரிக்கை');

  static String activeProducts(BuildContext context) =>
      tr(context, en: 'Active Products', ta: 'செயலில் உள்ள பொருட்கள்');

  static String recentOrders(BuildContext context) =>
      tr(context, en: 'Recent Live Orders', ta: 'சமீபத்திய நேரலை ஆர்டர்கள்');

  static String storeStatus(BuildContext context, bool isOpen) =>
      isOpen
          ? tr(context, en: 'Store Open (Accepting Orders)', ta: 'கடை திறந்துள்ளது (ஆர்டர்கள் பெறப்படுகின்றன)')
          : tr(context, en: 'Store Closed', ta: 'கடை மூடப்பட்டுள்ளது');

  // --- Order Status Translations ---
  static String statusNew(BuildContext context) =>
      tr(context, en: 'New Order', ta: 'புதிய ஆர்டர்');

  static String statusAccepted(BuildContext context) =>
      tr(context, en: 'Accepted', ta: 'ஏற்றுக்கொள்ளப்பட்டது');

  static String statusPreparing(BuildContext context) =>
      tr(context, en: 'Preparing', ta: 'தயாராகிறது');

  static String statusReady(BuildContext context) =>
      tr(context, en: 'Ready for Pickup', ta: 'எடுக்கத் தயார்');

  static String statusOutForDelivery(BuildContext context) =>
      tr(context, en: 'Out for Delivery', ta: 'டெலிவரிக்குச் செல்கிறது');

  static String statusDelivered(BuildContext context) =>
      tr(context, en: 'Delivered', ta: 'டெலிவரி செய்யப்பட்டது');

  static String statusCancelled(BuildContext context) =>
      tr(context, en: 'Cancelled', ta: 'ரத்து செய்யப்பட்டது');

  // --- Inventory Translations ---
  static String inventoryTitle(BuildContext context) =>
      tr(context, en: 'Inventory Management', ta: 'இருப்பு மேலாண்மை');

  static String healthScore(BuildContext context) =>
      tr(context, en: 'Inventory Health Index', ta: 'இருப்பு நிலை குறியீடு');

  static String inStock(BuildContext context) =>
      tr(context, en: 'In Stock', ta: 'இருப்பில் உள்ளது');

  static String lowStock(BuildContext context) =>
      tr(context, en: 'Low Stock', ta: 'குறைந்த இருப்பு');

  static String outOfStock(BuildContext context) =>
      tr(context, en: 'Out of Stock', ta: 'இருப்பு இல்லை');

  static String stockHistory(BuildContext context) =>
      tr(context, en: 'Stock Movement Logs', ta: 'இருப்பு வரலாற்றுப் பதிவுகள்');

  // --- Delivery Partner Translations ---
  static String incomingOrder(BuildContext context) =>
      tr(context, en: 'Incoming Delivery Request', ta: 'புதிய டெலிவரி கோரிக்கை');

  static String acceptDelivery(BuildContext context) =>
      tr(context, en: 'Accept Delivery', ta: 'டெலிவரியை ஏற்கவும்');

  static String navigateToStore(BuildContext context) =>
      tr(context, en: 'Navigate to Store', ta: 'கடைக்கு வழிகாட்டுக');

  static String confirmPickup(BuildContext context) =>
      tr(context, en: 'Confirm Pickup', ta: 'பொருளை எடுத்ததை உறுதிசெய்');

  static String navigateToCustomer(BuildContext context) =>
      tr(context, en: 'Navigate to Customer', ta: 'வாடிக்கையாளருக்கு வழிகாட்டுக');

  static String completeDelivery(BuildContext context) =>
      tr(context, en: 'Complete Delivery', ta: 'டெலிவரியை முடிக்கவும்');

  // --- Rating & Review Translations ---
  static String ratingsAndReviews(BuildContext context) =>
      tr(context, en: 'Rating & Reviews', ta: 'மதிப்பீடு & மதிப்புரைகள்');

  static String customerFeedback(BuildContext context) =>
      tr(context, en: 'Customer Feedback', ta: 'வாடிக்கையாளர் கருத்து');

  static String overallRating(BuildContext context) =>
      tr(context, en: 'Overall Rating', ta: 'ஒட்டுமொத்த மதிப்பீடு');

  static String restaurantRating(BuildContext context) =>
      tr(context, en: 'Restaurant Rating', ta: 'உணவக மதிப்பீடு');

  static String productRating(BuildContext context) =>
      tr(context, en: 'Product Rating', ta: 'பொருள் மதிப்பீடு');

  static String customerReviews(BuildContext context) =>
      tr(context, en: 'Customer Reviews', ta: 'வாடிக்கையாளர் மதிப்புரைகள்');

  static String reviews(BuildContext context) =>
      tr(context, en: 'reviews', ta: 'மதிப்புரைகள்');

  static String ratingBreakdown(BuildContext context) =>
      tr(context, en: 'Rating Breakdown', ta: 'மதிப்பீட்டு பிரிவு');

  static String allReviews(BuildContext context) =>
      tr(context, en: 'All Reviews', ta: 'அனைத்து மதிப்புரைகள்');

  static String needsReply(BuildContext context) =>
      tr(context, en: 'Needs Reply', ta: 'பதில் தேவை');

  static String replied(BuildContext context) =>
      tr(context, en: 'Replied', ta: 'பதிலளிக்கப்பட்டது');

  static String flagged(BuildContext context) =>
      tr(context, en: 'Flagged', ta: 'குறியிடப்பட்டது');

  static String starShort(BuildContext context) => '★';

  static String fiveStars(BuildContext context) =>
      tr(context, en: '5 Stars', ta: '5 நட்சத்திரங்கள்');

  static String fourStars(BuildContext context) =>
      tr(context, en: '4 Stars', ta: '4 நட்சத்திரங்கள்');

  static String threeStars(BuildContext context) =>
      tr(context, en: '3 Stars', ta: '3 நட்சத்திரங்கள்');

  static String twoStars(BuildContext context) =>
      tr(context, en: '2 Stars', ta: '2 நட்சத்திரங்கள்');

  static String oneStar(BuildContext context) =>
      tr(context, en: '1 Star', ta: '1 நட்சத்திரம்');

  static String replyToCustomer(BuildContext context) =>
      tr(context, en: 'Reply as Restaurant', ta: 'உணவகமாக பதிலளிக்கவும்');

  static String editReply(BuildContext context) =>
      tr(context, en: 'Edit Reply', ta: 'பதிலைத் திருத்து');

  static String sendReply(BuildContext context) =>
      tr(context, en: 'Send Reply', ta: 'பதிலை அனுப்பு');

  static String writeReply(BuildContext context) =>
      tr(context, en: 'Write your reply...', ta: 'உங்கள் பதிலை எழுதுங்கள்...');

  static String sellerReply(BuildContext context) =>
      tr(context, en: 'Seller Reply', ta: 'விற்பனையாளர் பதில்');

  static String storeResponse(BuildContext context) =>
      tr(context, en: 'Store Response', ta: 'கடை பதில்');

  static String reportReview(BuildContext context) =>
      tr(context, en: 'Report Review', ta: 'மதிப்புரையைப் புகாரளி');

  static String reportInappropriate(BuildContext context) =>
      tr(context, en: 'Report Inappropriate Review', ta: 'பொருத்தமற்ற மதிப்புரையைப் புகாரளி');

  static String reportAbusive(BuildContext context) =>
      tr(context, en: 'Abusive/Offensive', ta: 'தவறான/புண்படுத்தும்');

  static String reportIrrelevant(BuildContext context) =>
      tr(context, en: 'Irrelevant', ta: 'பொருத்தமற்றது');

  static String other(BuildContext context) =>
      tr(context, en: 'Other', ta: 'மற்றவை');

  static String reportedUnderReview(BuildContext context) =>
      tr(context, en: 'Reported - Under Review', ta: 'புகாரளிக்கப்பட்டது - மதிப்பாய்வில்');

  static String reviewReportedSuccess(BuildContext context) =>
      tr(context, en: 'Review reported. Thank you for your feedback.',
          ta: 'மதிப்புரை புகாரளிக்கப்பட்டது. உங்கள் கருத்துக்கு நன்றி.');

  static String replySubmittedSuccess(BuildContext context) =>
      tr(context, en: 'Reply submitted successfully.',
          ta: 'பதில் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது.');

  static String replyFailed(BuildContext context) =>
      tr(context, en: 'Failed to submit reply.', ta: 'பதிலை சமர்ப்பிக்க இயலவில்லை.');

  static String reportFailed(BuildContext context) =>
      tr(context, en: 'Failed to report review.', ta: 'மதிப்புரையைப் புகாரளிக்க இயலவில்லை.');

  static String noFilteredReviews(BuildContext context) =>
      tr(context, en: 'No reviews match your filter.',
          ta: 'உங்கள் வடிப்பானுக்கு பொருந்தும் மதிப்புரைகள் இல்லை.');

  static String retry(BuildContext context) =>
      tr(context, en: 'Retry', ta: 'மீண்டும் முயற்சி');
}
