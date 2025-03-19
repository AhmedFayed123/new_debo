import 'dart:io';
import 'dart:ui';

import 'package:debo/pages/splash.dart';
import 'package:debo/provider/avatarprovider.dart';
import 'package:debo/provider/bottombarprovider.dart';
import 'package:debo/provider/comment_provider.dart';
import 'package:debo/provider/connectivityprovider.dart';
import 'package:debo/provider/episodeprovider.dart';
import 'package:debo/provider/findprovider.dart';
import 'package:debo/provider/generalprovider.dart';
import 'package:debo/provider/homeprovider.dart';
import 'package:debo/provider/like_provider.dart';
import 'package:debo/provider/myspaceprovider.dart';
import 'package:debo/provider/paymentprovider.dart';
import 'package:debo/provider/playerprovider.dart';
import 'package:debo/provider/profileprovider.dart';
import 'package:debo/provider/purchaselistprovider.dart';
import 'package:debo/provider/rentstoreprovider.dart';
import 'package:debo/provider/searchprovider.dart';
import 'package:debo/provider/sectionbytypeprovider.dart';
import 'package:debo/provider/sectiondataprovider.dart';
import 'package:debo/provider/sectionviewallprovider.dart';
import 'package:debo/provider/showdetailsprovider.dart';
import 'package:debo/provider/showdownloadprovider.dart';
import 'package:debo/provider/subhistoryprovider.dart';
import 'package:debo/provider/subscriptionprovider.dart';
import 'package:debo/provider/videobyidprovider.dart';
import 'package:debo/provider/videodetailsprovider.dart';
import 'package:debo/provider/videodownloadprovider.dart';
import 'package:debo/provider/viewallprovider.dart';
import 'package:debo/provider/watchlistprovider.dart';
import 'package:debo/pushservice/pushnotificationservice.dart';
import 'package:debo/routes/routes_config.dart';
import 'package:debo/utils/color.dart';
import 'package:debo/utils/constant.dart';
import 'package:debo/utils/sharedpre.dart';
import 'package:debo/utils/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';
import 'model/download_item.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final RemoteNotification? notification = message.notification;
  // If `onMessage` is triggered with a notification, construct our own
  // local notification to show to users using the created channel.
  if (notification != null) {
    printLog("notification title =====> ${notification.title}");
    printLog("notification body ======> ${notification.body}");
    printLog("notification message ===> ${message.data}");
    Map<String, dynamic>? notificationData = message.data;
    printLog("notificationData =======> $notificationData");
    String? notifyType = notificationData["type"];
    String? deviceToken = notificationData["deviceToken"];
    String? deviceType = notificationData["deviceType"];
    printLog("notifyType =======> $notifyType");
    printLog("deviceToken ======> $deviceToken");
    printLog("deviceType =======> $deviceType");
    if (notifyType == "logout") {
      // Firebase Signout
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await Utils.setUserId(null);
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await MobileAds.instance.initialize();

    /* Initialize Hive Start */
    final appDocumentDir = await getApplicationDocumentsDirectory();
    printLog("appDocumentDir Path ==> ${appDocumentDir.path}");
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(DownloadItemAdapter());
    Hive.registerAdapter(SessionItemAdapter());
    Hive.registerAdapter(EpisodeItemAdapter());
    /* Initialize Hive End */
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /* Push Notification Set-up */
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  /* Push Notification Set-up */

  await Locales.init([
    'en',
    'af',
    'ar',
    'de',
    'es',
    'fr',
    'gu',
    'hi',
    'id',
    'nl',
    'pt',
    'sq',
    'tr',
    'vi'
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => BottombarProvider()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => EpisodeProvider()),
        ChangeNotifierProvider(create: (_) => FindProvider()),
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => MySpaceProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PurchaselistProvider()),
        ChangeNotifierProvider(create: (_) => RentStoreProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => SectionByTypeProvider()),
        ChangeNotifierProvider(create: (_) => SectionDataProvider()),
        ChangeNotifierProvider(create: (_) => ShowDownloadProvider()),
        ChangeNotifierProvider(create: (_) => ShowDetailsProvider()),
        ChangeNotifierProvider(create: (_) => SubHistoryProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => SectionViewAllProvider()),
        ChangeNotifierProvider(create: (_) => ViewAllProvider()),
        ChangeNotifierProvider(create: (_) => VideoByIDProvider()),
        ChangeNotifierProvider(create: (_) => VideoDetailsProvider()),
        ChangeNotifierProvider(create: (_) => VideoDownloadProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (context) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),

      ],
      child: const MyApp(),
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  SharedPre sharedPre = SharedPre();
  late ConnectivityProvider connectivityProvider;
  late ProfileProvider profileProvider;

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);
    // if (!kIsWeb) Utils.preventScreenCapture();

    /* Push Notification Set-up */
    PushNotificationService().setupInteractedMessage(context);
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    /* Push Notification Set-up */

    if (!kIsWeb) _fetchIntro();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await connectivityProvider.initConnectivity(context);
      await _getDeviceInfo();
      _getData();
    });
    super.initState();
  }

  _getData() async {
    Constant.userID = await sharedPre.read('userid');
    Constant.userIsKid = await sharedPre.readBool(Constant.profileUserKey);
    printLog('_getData userID ===========> ${Constant.userID}');
    printLog('_getData userIsKid ========> ${Constant.userIsKid}');
    printLog('_getData currentDeviceId ==> ${Constant.currentDeviceId}');

    if (Constant.userIsKid == null) {
      await Utils.setUserMode(false);
    }

    /* *********** Check For Device START *********** */
    if (connectivityProvider.isOnline && Constant.userID != null) {
      await profileProvider.getDeviceSyncList();
      if (profileProvider.deviceSyncModel.result != null &&
          (profileProvider.deviceSyncModel.result?.length ?? 0) > 0) {
        bool? isDeviceContains =
            profileProvider.deviceSyncModel.result?.any((deviceItem) {
          printLog("_getData deviceList userId ====> ${deviceItem.userId}");
          printLog("_getData deviceList deviceId ==> ${deviceItem.deviceId}");
          return ((deviceItem.deviceId ?? "") == Constant.currentDeviceId);
        });
        printLog("_getData isDeviceContains ====> $isDeviceContains");
        if (isDeviceContains == false) {
          PushNotificationService.onLogoutDelete();
          return;
        }
      }
    }
    /* *********** Check For Device END ************* */

    /* Initialize Hive */
    if (!kIsWeb) {
      await Utils.initializeHiveBoxes();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    printLog('didChangeAppLifecycleState state =====> ${state.name}');
    switch (state) {
      case AppLifecycleState.resumed:
        if (!mounted) return;
        _getData();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) {
        if (kIsWeb) {
          return _buildForWeb(locale: locale);
        } else {
          return _buildForOther(locale: locale);
        }
      },
    );
  }

  Widget _buildForWeb({required Locale? locale}) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: RoutesConfig().goRouter,
      theme: ThemeData(
        primaryColor: colorPrimary,
        primaryColorDark: colorPrimaryDark,
        primaryColorLight: colorPrimary,
        scaffoldBackgroundColor: appBgColor,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: kIsWeb
              ? {
                  for (final platform in TargetPlatform.values)
                    platform: const NoTransitionsBuilder(),
                }
              : const {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
        ),
      ).copyWith(
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: WidgetStateProperty.all(white),
          trackVisibility: WidgetStateProperty.all(true),
          trackColor: WidgetStateProperty.all(white.withOpacity(0.5)),
        ),
      ),
      title: Constant.appName,
      localizationsDelegates: Locales.delegates,
      supportedLocales: Locales.supportedLocales,
      locale: locale,
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        return locale;
      },
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 360, name: MOBILE),
            const Breakpoint(start: 361, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1000, name: DESKTOP),
            const Breakpoint(start: 1001, end: double.infinity, name: '4K'),
          ],
        );
      },
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
          PointerDeviceKind.trackpad
        },
      ),
    );
  }

  Widget _buildForOther({required Locale? locale}) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver], //HERE
      theme: ThemeData(
        primaryColor: colorPrimary,
        primaryColorDark: colorPrimaryDark,
        primaryColorLight: colorPrimary,
        scaffoldBackgroundColor: appBgColor,
      ).copyWith(
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: WidgetStateProperty.all(white),
          trackVisibility: WidgetStateProperty.all(true),
          trackColor: WidgetStateProperty.all(white.withOpacity(0.5)),
        ),
      ),
      title: Constant.appName,
      localizationsDelegates: Locales.delegates,
      supportedLocales: Locales.supportedLocales,
      locale: locale,
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        return locale;
      },
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        );
      },
      home: const Splash(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
          PointerDeviceKind.trackpad
        },
      ),
    );
  }

  _fetchIntro() async {
    final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    if (connectivityProvider.isOnline) {
      generalsetting.getIntroPages();
    }
  }

  _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      printLog('_getDeviceInfo Running on : ${webBrowserInfo.platform}');
      printLog('_getDeviceInfo userAgent ======>> ${webBrowserInfo.userAgent}');
      Constant.deviceName = webBrowserInfo.platform ?? '';

      /* <<<<<< Web DeviceId START >>>>>> */
      final cookies = html.document.cookie?.split('; ') ?? [];
      final deviceIdCookie = cookies.firstWhere(
        (cookie) => cookie.startsWith('device_id='),
        orElse: () => '',
      );

      printLog('_getDeviceInfo deviceIdCookie =====>> $deviceIdCookie');
      if (deviceIdCookie.isNotEmpty) {
        printLog(
            '_getDeviceInfo deviceIdCookie =====>> ${deviceIdCookie.split('=')[1]}');
        Constant.currentDeviceId = deviceIdCookie.split('=')[1];
      } else {
        final uuid = const Uuid().v4();
        final generatedDeviceId = Utils.sha256ofString(uuid);
        printLog('_getDeviceInfo uuid ===============>> $uuid');
        printLog('_getDeviceInfo generatedDeviceId ==>> $generatedDeviceId');
        html.document.cookie =
            'device_id=$generatedDeviceId; path=/; max-age=31536000'; // 1 year
        Constant.currentDeviceId = generatedDeviceId;
      }
      /* <<<<<< Web DeviceId END >>>>>> */
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        Constant.isTV =
            androidInfo.systemFeatures.contains('android.software.leanback');
        printLog("_getDeviceInfo isTV ==============> ${Constant.isTV}");
        printLog('_getDeviceInfo Running on : ${androidInfo.product}');
        Constant.deviceName = "${androidInfo.brand} ${androidInfo.product}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        printLog('_getDeviceInfo Running on : ${iosInfo.utsname.machine}');
        Constant.deviceName = iosInfo.utsname.machine;
      }

      /* <<<<<< DeviceId START >>>>>> */
      try {
        String consistentUdid = await FlutterUdid.consistentUdid;
        String udid = await FlutterUdid.udid;
        printLog("_getDeviceInfo consistentUdid ======> $consistentUdid");
        printLog("_getDeviceInfo udid ================> $udid");
        Constant.currentDeviceId = consistentUdid;
      } on PlatformException catch (e) {
        printLog("_getDeviceInfo PlatformException ===> $e");
      }
      /* <<<<<< DeviceId END >>>>>> */
    }
    printLog(
        "===========================\nDeviceName => ${Constant.deviceName}\nDeviceId => ${Constant.currentDeviceId}\n===========================");
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    return child!;
  }
}
