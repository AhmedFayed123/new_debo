
import 'package:flutter/material.dart';

import '../model/sectionbannermodel.dart';
import '../model/sectionlistmodel.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class SectionByTypeProvider extends ChangeNotifier {
  SectionBannerModel sectionBannerModel = SectionBannerModel();
  SectionListModel sectionListModel = SectionListModel();

  bool loadingBanner = false, loadingSection = false;
  int? cBannerIndex = 0;

  setLoading(bool flagLoading) {
    loadingBanner = flagLoading;
    loadingSection = flagLoading;
    notifyListeners();
  }

  Future<void> getSectionBanner(typeId, isHomePage) async {
    printLog("getSectionBanner typeId :==> $typeId");
    printLog("getSectionBanner isHomePage :==> $isHomePage");
    loadingBanner = true;
    sectionBannerModel = await ApiService().sectionBanner(typeId, isHomePage);
    printLog("get_banner status :==> ${sectionBannerModel.status}");
    printLog("get_banner message :==> ${sectionBannerModel.message}");
    loadingBanner = false;
    notifyListeners();
  }

  Future<void> getSectionList(typeId, isHomePage, pageNo) async {
    printLog("getSectionList typeId :======> $typeId");
    printLog("getSectionList isHomePage :==> $isHomePage");
    printLog("getSectionList pageNo :======> $pageNo");
    loadingSection = true;
    sectionListModel =
        await ApiService().sectionList(typeId, isHomePage, pageNo);
    printLog("section_list status :==> ${sectionListModel.status}");
    printLog("section_list message :==> ${sectionListModel.message}");
    loadingSection = false;
    notifyListeners();
  }

  setCurrentBanner(index) {
    cBannerIndex = index;
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    sectionBannerModel = SectionBannerModel();
    sectionListModel = SectionListModel();
  }
}
