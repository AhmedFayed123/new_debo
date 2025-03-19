import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:debo/pages/rentstore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../provider/bottombarprovider.dart';
import '../provider/connectivityprovider.dart';
import '../provider/generalprovider.dart';
import '../provider/homeprovider.dart';
import '../provider/profileprovider.dart';
import '../provider/sectiondataprovider.dart';
import '../routes/routes_constant.dart';
import '../utils/adhelper.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/sharedpre.dart';
import '../utils/strings.dart';
import '../utils/utils.dart';
import '../widget/myimage.dart';
import '../widget/myusernetworkimg.dart';
import 'find.dart';
import 'home.dart';
import 'mydownloads.dart';
import 'myspace.dart';
import 'nointernet.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => BottombarState();
}

class BottombarState extends State<Bottombar> with RouteAware {
  late SectionDataProvider sectionDataProvider;
  late ConnectivityProvider connectivityProvider;
  late GeneralProvider generalProvider;
  late HomeProvider homeProvider;
  late BottombarProvider bottombarProvider;
  SharedPre sharedPre = SharedPre();
  String? rentMenuStatus, downloadStatus;
  DateTime? currentBackPressTime;

  List<Widget> widgetOptions = <Widget>[];

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    printLog(
        "didPopNext bottomNavIndex ===> ${bottombarProvider.bottomNavIndex}");
    super.didPopNext();
  }

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    bottombarProvider = Provider.of<BottombarProvider>(context, listen: false);
    printLog(
        "initState bottomNavIndex ===> ${bottombarProvider.bottomNavIndex}");
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);
    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    if (widgetOptions.isEmpty) {
      widgetOptions = <Widget>[];
      widgetOptions = <Widget>[
        const Home(pageName: ""),
        const Find(),
        const MySpace(),
      ];
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
      /* Check Internet Connection */
      connectivityProvider.connectivity.onConnectivityChanged.listen(
        (result) {
          if (result.isNotEmpty) {
            printLog('connectivityResult =======> ${result[0].name}');
            if (result[0] == ConnectivityResult.mobile ||
                result[0] == ConnectivityResult.wifi) {
            } else {
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const NoInternet()),
                (Route<dynamic> route) => false,
              ).then(
                (value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const NoInternet()),
                  );
                },
              );
              return;
            }
          }
        },
      );
    });
  }

  _getData() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    if (connectivityProvider.isOnline) {
      if (!mounted) return;
      await generalProvider.getGeneralsetting(context);

      rentMenuStatus = await Utils.configByStatus(status: Constant.rentStatus);
      downloadStatus =
          await Utils.configByStatus(status: Constant.downloadStatus);
      printLog('_getData rentMenuStatus ==> $rentMenuStatus');
      printLog('_getData downloadStatus ==> $downloadStatus');
      printLog('_getData userIsKid =======> ${Constant.userIsKid}');

      if ((rentMenuStatus != null && rentMenuStatus == "1") &&
          Constant.userIsKid == false) {
        widgetOptions.insert(2, const RentStore());
      } else {
        if (widgetOptions.contains(const RentStore())) {
          widgetOptions.removeAt(2);
        }
      }
      if (downloadStatus != null && downloadStatus == "1") {
        widgetOptions.insert((Constant.userIsKid == true) ? 2 : 3,
            const MyDownloads(viewFrom: RoutesConstant.homePage));
      } else {
        if (widgetOptions
            .contains(const MyDownloads(viewFrom: RoutesConstant.homePage))) {
          widgetOptions.removeAt((Constant.userIsKid == true) ? 2 : 3);
        }
      }
      printLog('_getData widgetOptions ===> ${widgetOptions.length}');

      if (!mounted) return;
      if (Constant.userID != null) {
        await profileProvider.getProfile(context);
      } else {
        Utils.updatePremium("0");
        Utils.loadAds(context);
      }
    }

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _onItemTapped(int index) async {
    AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
      if (index == 0) {
        getHomeTabData();
      }
      if (!mounted) return;
      await bottombarProvider.setBottomNavIndex(index);
      printLog("bottomNavIndex ===> ${bottombarProvider.bottomNavIndex}");
      printLog("widget length ====> ${widgetOptions.length}");
    });
  }

  Future<void> getHomeTabData() async {
    await sectionDataProvider.setLoading(true);
    await sectionDataProvider.getSectionBanner("0", "1");
    await sectionDataProvider.getSectionList("0", "1", 1);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: _buildOnlinePage(),
    );
  }

  Widget _buildOnlinePage() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Consumer<BottombarProvider>(
              builder: (context, bottombarProvider, child) {
                return Center(
                  child: widgetOptions[bottombarProvider.bottomNavIndex],
                );
              },
            ),
          ),
          /* AdMob Banner */
          Utils.showBannerAd(context),
        ],
      ),
      bottomNavigationBar: Consumer<BottombarProvider>(
        builder: (context, bottombarProvider, child) {
          return Visibility(
            visible: bottombarProvider.isShowAppbar,
            maintainAnimation: true,
            maintainState: true,
            child: AnimatedOpacity(
              opacity: bottombarProvider.isShowAppbar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: !(bottombarProvider.isShowAppbar)
                  ? const SizedBox.shrink()
                  : BottomAppBar(
                      height: kBottomNavigationBarHeight,
                      color: secondaryBgColor,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      elevation: 0,
                      shadowColor: edtViewShadowColor,
                      child: BottomNavigationBar(
                        currentIndex: bottombarProvider.bottomNavIndex,
                        backgroundColor: secondaryBgColor,
                        elevation: 0,
                        selectedLabelStyle: GoogleFonts.inter(
                          fontSize: Dimens.isTablet(context)
                              ? Dimens.textSmall
                              : Dimens.textExtraSmall,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          color: colorPrimary,
                        ),
                        unselectedLabelStyle: GoogleFonts.inter(
                          fontSize: Dimens.isTablet(context)
                              ? Dimens.textSmall
                              : Dimens.textExtraSmall,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w500,
                          color: colorPrimary,
                        ),
                        selectedFontSize: Dimens.isTablet(context)
                            ? Dimens.textSmall
                            : Dimens.textExtraSmall,
                        unselectedFontSize: Dimens.isTablet(context)
                            ? Dimens.textSmall
                            : Dimens.textExtraSmall,
                        unselectedItemColor: defaultIconColor,
                        selectedItemColor: colorPrimary,
                        landscapeLayout:
                            BottomNavigationBarLandscapeLayout.centered,
                        type: BottomNavigationBarType.fixed,
                        items: [
                          BottomNavigationBarItem(
                            backgroundColor: black,
                            label: bottomView1,
                            activeIcon: _buildBottomNavIcon(
                                iconName: 'ic_home', iconColor: colorPrimary),
                            icon: _buildBottomNavIcon(
                                iconName: 'ic_home',
                                iconColor: defaultIconColor),
                          ),
                          BottomNavigationBarItem(
                            backgroundColor: black,
                            label: bottomView2,
                            activeIcon: _buildBottomNavIcon(
                                iconName: 'ic_find', iconColor: colorPrimary),
                            icon: _buildBottomNavIcon(
                                iconName: 'ic_find',
                                iconColor: defaultIconColor),
                          ),
                          if ((rentMenuStatus != null &&
                                  rentMenuStatus == "1") &&
                              Constant.userIsKid == false)
                            BottomNavigationBarItem(
                              backgroundColor: black,
                              label: bottomView3,
                              activeIcon: _buildBottomNavIcon(
                                  iconName: 'ic_store',
                                  iconColor: colorPrimary),
                              icon: _buildBottomNavIcon(
                                  iconName: 'ic_store',
                                  iconColor: defaultIconColor),
                            ),
                          if (downloadStatus != null && downloadStatus == "1")
                            BottomNavigationBarItem(
                              backgroundColor: black,
                              label: bottomView4,
                              activeIcon: _buildBottomNavIcon(
                                  iconName: 'ic_download',
                                  iconColor: colorPrimary),
                              icon: _buildBottomNavIcon(
                                  iconName: 'ic_download',
                                  iconColor: defaultIconColor),
                            ),
                          BottomNavigationBarItem(
                            backgroundColor: black,
                            label: bottomView5,
                            activeIcon: _buildBottomNavProfileIcon(
                                iconColor: colorPrimary),
                            icon: _buildBottomNavProfileIcon(
                                iconColor: defaultIconColor),
                          ),
                        ],
                        onTap: _onItemTapped,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavIcon({
    required String iconName,
    required Color? iconColor,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Image.asset(
          "assets/images/$iconName.png",
          width: 18,
          height: 18,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildBottomNavProfileIcon({
    required Color? iconColor,
  }) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.profileModel.result != null &&
            (profileProvider.profileModel.result?.length ?? 0) > 0) {
          return Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: (Constant.userIsKid == true)
                    ? MyImage(
                        imagePath: 'kids.png',
                        fit: BoxFit.cover,
                        height: 20,
                        width: 20,
                      )
                    : MyUserNetworkImage(
                        imageUrl:
                            profileProvider.profileModel.result?[0].image ?? "",
                        fit: BoxFit.cover,
                        height: 20,
                        width: 20,
                      ),
              ),
            ),
          );
        } else {
          return _buildBottomNavIcon(
            iconName: 'ic_stuff',
            iconColor: iconColor,
          );
        }
      },
    );
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (bottombarProvider.bottomNavIndex == 0) {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        Utils.showSnackbar(context, "", "exit_warning", true);
        return;
      }
      SystemNavigator.pop();
    } else {
      _onItemTapped(0);
    }
  }
}
