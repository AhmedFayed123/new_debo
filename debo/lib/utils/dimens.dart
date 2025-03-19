import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constant.dart';

class Dimens {
  // Dimentions START
  static double appIconSizeWeb = 70;

  static double minTabletWidth = 450;

  static double appBarHeight = 60;
  static double appBarTextSize = 20;
  static double textFieldHeight = 50;
  static double textFieldHeightWeb = 60;
  static double buttonHeight = 52;
  static double defaultBtnHeight = 52;
  static double defaultBtnHeightWeb = 40;
  static double backBtnHeight = 15;
  static double backBtnWidth = 19;
  static double homeTabHeightSmall = 60;
  static double homeTabHeight = 75;
  static double tabSeasonHeight = 45;
  static double appBarWebHeight = 150;
  static double appBarFullHeight = 110;
  static double rentTabHeight = 65;
  static double searchTabHeight = 50;
  static double heightAppBarIcon = 120;
  static double widthAppBarIcon = 120;
  static double widthHomeUser = 40;
  static double heightHomeUser = 40;

  static double cardRadius = 6;
  static double cardRadiusWeb = 3;
  static double cardRadiusSmall = 1;
  static double spaceBetweenCards = 5;
  static double spaceBetweenCardsWeb = 8;
  static double spaceBetweenCategory = 8;
  static double spaceBetweenCategoryWeb = 10;
  static double menuRadius = 38;
  static double bottomWebPadding = 70;

  /* Ratio */
  static double portRatio = 0.8;
  static double landRatio = 1.91;
  /* Ratio */

  static double widthPort = 125;
  static double heightPort = 180;
  static double widthLand = 195;
  static double heightLand = 120;
  static double widthPortOther = 125;
  static double heightPortOther = 175;
  static double widthPortOtherWeb = 175;
  static double heightPortOtherWeb = 240;
  static double widthPortWeb = 175;
  static double heightPortWeb = 245;
  static double widthLandWeb = 315;
  static double heightLandWeb = 180;

  static double widthPortBig = 165;
  static double heightPortBig = 305;
  static double widthLandBig = 305;
  static double heightLandBig = 169;
  static double widthPortBigWeb = 225;
  static double heightPortBigWeb = 390;
  static double widthLandBigWeb = 410;
  static double heightLandBigWeb = 225;

  static double widthSquare = 150;
  static double heightSquare = 150;
  static double widthSquareWeb = 250;
  static double heightSquareWeb = 250;

  static double widthContiLand = 215;
  static double heightContiLand = 105;

  static double widthCast = 110;
  static double heightCast = 165;
  static double widthCastWeb = 175;
  static double heightCastWeb = 245;

  static double widthLang = 120;
  static double heightLang = 70;
  static double widthLangWeb = 150;
  static double heightLangWeb = 100;
  static double heightLangImage = 18;
  static double heightLangImageWeb = 28;
  static double widthGen = 80;
  static double heightGen = 80;
  static double widthGenWeb = 100;
  static double heightGenWeb = 100;
  static double heightGenTotal = 105;
  static double heightGenTotalWeb = 135;
  static double widthChannel = 80;
  static double heightChannel = 58;
  static double widthChannelWeb = 120;
  static double heightChannelWeb = 98;
  static double widthGenDialog = 135;
  static double heightGenDialog = 65;

  static double heightWatchlist = 110;

  static double homeBanner = 680;
  static double homeWebBanner = 500;
  static double webBannerImgPr = 0.59; // Should be less than 1.0
  static double detailPoster = 187;
  static double detailPosterWeb = 360;
  static double detailTabs = 50;
  static double featureSize = 50;
  static double featureIconSize = 15;
  static double featureWebSize = 30;
  static double featureIconWebSize = 13;
  static double epiPoster = 240;
  static double castCrewPoster = 525;
  static double channelPoster = 222;
  static double channelBanner = 250;
  static double channelWebBanner = 350;
  static double rentBanner = 103;
  static double widthEpiLand = 100;
  static double heightEpiLand = 62;
  static double widthEpiLandWeb = 248.3;
  static double heightEpiLandWeb = 130;

  static double widthAvatarWeb = 120;
  static double heightAvatarWeb = 120;
  static double widthAvatar = 90;
  static double heightAvatar = 90;
  static double widthProfilesWeb = 95;
  static double heightProfilesWeb = 95;
  static double widthProfiles = 60;
  static double heightProfiles = 60;

  static double widthPackage = 130;
  static double widthPackageWeb = 200;

  static double minHeightSettings = 45;
  static double heightHistory = 70;

  static double minHtDialogContent = 42;
  static double dialogIconSize = 20;
  static double dialogButtonHeight = 48;

  static double heightSocialBtn = 35;
  static double widthSocialBtn = 35;
  // Dimentions END

  /* General TextSize */
  static double textExtraSmall = 10;
  static double textSmall = 12;
  static double textSmallMedium = 14;
  static double textMedium = 15;
  static double textSmallWeb = 15;
  static double textExtraSmallWeb = 14;
  static double textMediumWeb = 17;
  static double textSmallMediumWeb = 16;
  static double text16 = 16;
  static double text17 = 17;
  static double text18 = 18;
  static double text20 = 20;
  // Dimentions END

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > Dimens.minTabletWidth;
  }

  static bool isBigScreen(BuildContext context) {
    return ((kIsWeb || Constant.isTV) &&
        MediaQuery.of(context).size.width > 840);
  }

  static double getResponsiveHeight(BuildContext context, double sideMargins) {
    return ((MediaQuery.of(context).size.width - sideMargins) /
        Dimens.landRatio);
  }
}
