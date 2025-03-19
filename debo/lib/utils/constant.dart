

import '../model/qualitymodel.dart';
import '../model/subtitlemodel.dart';

class Constant {
  static const String baseurl = 'https://homecima.com/public/api/';

  static String appName = "debo";
  static String appPackageName = "com.debo.debo";
  static String appleAppId = "";

  /* Vapid Key to generate Device Token For Web */
  /* Firebase console >> Project Settings >> Cloud Messaging >> Web Configuration >> Copy Key Pair >> Add in Admin's App Setting menu */
  static String? vapidKeyForWeb;
  static String? accessToken;

  /* Constant for TV check */
  static bool isTV = false;

  /* Device Info */
  static String deviceName = "";
  static String currentDeviceId = "";

  static String? userID;
  static bool? userIsKid;
  static String currencySymbol = "";
  static String currency = "";
  static const String parentLockKey = "PARENT_LOCK_STATUS";
  static const String profileUserKey = "USER_IS_KID";

  static String androidAppShareUrlDesc =
      "Let me recommend you this application\n\n$androidAppUrl";
  static String iosAppShareUrlDesc =
      "Let me recommend you this application\n\n$iosAppUrl";
  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=${Constant.appPackageName}";
  static String iosAppUrl =
      "https://apps.apple.com/us/app/id${Constant.appleAppId}";

  static List<QualityModel> resolutionsUrls = [];
  static List<SubTitleModel> subtitleUrls = [];

  /* Download config */
  static String bgEncryptDecryptTask = 'encrypt_decrypt_task';
  static String hiveDownloadBox = 'DOWNLOADS';
  static String hiveSeasonDownloadBox = 'DOWNLOAD_SEASON';
  static String hiveEpiDownloadBox = 'DOWNLOAD_EPISODE';
  static String videoDownloadPort = 'video_downloader_send_port';
  static String showDownloadPort = 'show_downloader_send_port';
  static String hawkVIDEOList = "myVideoList_";
  static String hawkKIDSVIDEOList = "myKidsVideoList_";
  static String hawkSHOWList = "myShowList_";
  static String hawkSEASONList = "mySeasonList_";
  static String hawkEPISODEList = "myEpisodeList_";
  /* Download config */

  static int fixFourDigit = 1317;
  static int fixSixDigit = 161613;

  static int bannerDuration = 10000; // in milliseconds
  static int animationDuration = 800; // in milliseconds

  /* Show Ad By Type */
  static String rewardAdType = "rewardAd";
  static String interstialAdType = "interstialAd";

  /* Dynamic App Setting Keys (general_setting API) ****** */
  static const String trailerAutoPlay = "auto_play_trailer";
  static const String parentControlStatus = "parent_control_status";
  static const String multipleDeviceSync = "multiple_device_sync";
  static const String subscriptionStatus = "subscription_status";
  static const String activeTvStatus = "active_tv_status";
  static const String watchlistStatus = "watchlist_status";
  static const String downloadStatus = "download_status";
  static const String continueWatchingStatus = "continue_watching_status";
  static const String couponStatus = "coupon_status";
  static const String rentStatus = "rent_status";
  static const String introScreenStatus = "on_boarding_screen_status";
  /* ****** Dynamic App Setting Keys (general_setting API) */

  /* Stripe Checkout fields */
  // static const String webDomainURL = 'http://localhost:8080/'; //Localhost
  static const String webDomainURL = 'https://domain.com/'; //Normal Web Host
  static String? paymentMode =
      'subscription'; // Set paymentMode as 'payment' for Single Time purchase Packages (Not Recurring Packages)
  static String? publishableKey;
  static String? secretKey;
  static String? packagePriceId;
  static String? successURL;
  static String? cancelURL;
  static bool isStripePaySuccess = false;
  /* Stripe Checkout fields */
}
