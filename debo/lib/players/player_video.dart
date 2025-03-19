// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';
//
//
// import 'package:chewie/chewie.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_cast_video/flutter_cast_video.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
// import 'package:video_player/video_player.dart';
//
// import '../main.dart';
// import '../model/playermodel.dart';
// import '../provider/connectivityprovider.dart';
// import '../provider/playerprovider.dart';
// import '../routes/routes_constant.dart';
// import '../utils/color.dart';
// import '../utils/constant.dart';
// import '../utils/dimens.dart';
// import '../utils/strings.dart';
// import '../utils/utils.dart';
// import '../widget/mynetworkimg.dart';
// import '../widget/mytext.dart';
//
// String duration2String(Duration? dur, {showLive = 'Live'}) {
//   Duration duration = dur ?? const Duration();
//   if (duration.inSeconds <= 0) {
//     return showLive;
//   } else {
//     return duration.toString().split('.').first.padLeft(8, "0");
//   }
// }
//
// class PlayerVideo extends StatefulWidget {
//   final PlayerModel playerModel;
//   const PlayerVideo({
//     super.key,
//     required this.playerModel,
//   });
//
//   @override
//   State<PlayerVideo> createState() => _PlayerVideoState();
// }
//
// class _PlayerVideoState extends State<PlayerVideo>
//     with RouteAware, WidgetsBindingObserver {
//   late PlayerProvider playerProvider;
//   late ConnectivityProvider connectivityProvider;
//   int? playerCPosition, videoDuration;
//   ChewieController? _chewieController;
//   late VideoPlayerController _videoPlayerController;
//   SubtitleController? subtitleController;
//   bool subtitlesEnabled = false;
//
//   /* Chrome Cast START */
//   late ChromeCastController _chromeCastController;
//   AppState _state = AppState.idle;
//   bool _playingOnCasting = false;
//   Map<dynamic, dynamic> _mediaInfo = {};
//   /* Chrome Cast END */
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     printLog('didChangeAppLifecycleState state =====> ${state.name}');
//     switch (state) {
//       case AppLifecycleState.resumed:
//         if (connectivityProvider.isOnline) {
//           playerProvider.addRemoveDevice(1);
//         }
//         break;
//       case AppLifecycleState.paused:
//         if (connectivityProvider.isOnline) {
//           playerProvider.addRemoveDevice(2);
//         }
//         break;
//       default:
//         break;
//     }
//   }
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(this);
//     printLog("videoUrl ========> ${widget.playerModel.videoUrl}");
//     printLog("vUploadType ========> ${widget.playerModel.uploadType}");
//     playerProvider = Provider.of<PlayerProvider>(context, listen: false);
//     connectivityProvider =
//         Provider.of<ConnectivityProvider>(context, listen: false);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _playerInit();
//     });
//     super.initState();
//   }
//
//   @override
//   void didChangeDependencies() {
//     printLog("========= didChangeDependencies =========");
//     routeObserver.subscribe(this, ModalRoute.of(context)!);
//     super.didChangeDependencies();
//   }
//
//   @override
//   void didPop() {
//     printLog("========= didPop =========");
//     super.didPop();
//   }
//
//   @override
//   void didPopNext() {
//     printLog("========= didPopNext =========");
//     if (_chewieController == null) {
//       _playerInit();
//     }
//     super.didPopNext();
//   }
//
//   @override
//   void didPush() {
//     printLog("========= didPush =========");
//     super.didPush();
//   }
//
//   @override
//   void didPushNext() {
//     printLog("========= didPushNext =========");
//     super.didPushNext();
//   }
//
//   _playerInit() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     /* ******* Check Device Sync ******* */
//     if (connectivityProvider.isOnline &&
//         (widget.playerModel.playType == "Video" ||
//             widget.playerModel.playType == "Show")) {
//       await playerProvider.addRemoveDevice(1);
//       if (!playerProvider.isDeviceAdded) {
//         if (!mounted) return;
//         dynamic isNotWatching = await Utils.openWebDialog(
//           context: context,
//           newPage: RoutesConstant.cannotWatchPage,
//           oldPage: "",
//           reqText: "",
//         );
//         printLog("isNotWatching =========> $isNotWatching");
//         if (!mounted) return;
//         if (isNotWatching != null && isNotWatching == false) {
//           if (kIsWeb) {
//             if (context.canPop()) {
//               context.pop(false);
//             }
//           } else {
//             if (Navigator.canPop(context)) {
//               Navigator.pop(context, false);
//             }
//           }
//           return;
//         }
//       }
//     }
//     /* ************** */
//
//     /* Subtitles & Quality */
//     printLog("sSubTitleUrls Length =======> ${Constant.subtitleUrls.length}");
//     if (!kIsWeb) {
//       _loadSubtitle();
//       if (widget.playerModel.playType == "Video" ||
//           widget.playerModel.playType != "Show") {
//         if (Constant.resolutionsUrls.isNotEmpty) {
//           await playerProvider
//               .setCurrentQuality(Constant.resolutionsUrls[0].qualityName);
//         }
//       } else {
//         Constant.resolutionsUrls.clear();
//         Constant.resolutionsUrls = [];
//       }
//     }
//     /* ************** */
//
//     VideoPlayerController videoPlayerController;
//     if (!kIsWeb && widget.playerModel.playType == "Download") {
//       File? tempFile;
//
//       /* Decrypt Without Freez START ******************** */
//       final receivePort = ReceivePort();
//       var rootToken = RootIsolateToken.instance!;
//       final isolate = await Isolate.spawn(Utils.decryptFile, [
//         File(widget.playerModel.videoUrl ?? ""),
//         widget.playerModel.securityKey ?? "",
//         receivePort.sendPort,
//         rootToken
//       ]);
//       receivePort.listen((message) async {
//         if (message != null) {
//           tempFile = message;
//           printLog("tempFile ===isolate===> $tempFile");
//           videoPlayerController = VideoPlayerController.file(tempFile!);
//           receivePort.close();
//           isolate.kill(priority: Isolate.immediate);
//           await Future.wait([videoPlayerController.initialize()])
//               .then((value) async {
//             if (mounted) {
//               setState(() {
//                 _videoPlayerController = videoPlayerController;
//
//                 /* Chewie Controller */
//                 if (widget.playerModel.playType == "Video" ||
//                     widget.playerModel.playType == "Show" ||
//                     widget.playerModel.playType == "Download") {
//                   _setupController(
//                       startAt: Duration(
//                           milliseconds: widget.playerModel.stopTime ?? 0));
//                 } else {
//                   _setupController(startAt: Duration.zero);
//                 }
//               });
//             }
//           });
//         }
//       });
//       /* ********************** Decrypt Without Freez END */
//
//       if (tempFile != null) {
//         printLog("tempFile =======> $tempFile");
//         videoPlayerController = VideoPlayerController.file(tempFile!);
//         await Future.wait([videoPlayerController.initialize()])
//             .then((value) async {
//           if (mounted) {
//             setState(() {
//               _videoPlayerController = videoPlayerController;
//
//               /* Chewie Controller */
//               if (widget.playerModel.playType == "Video" ||
//                   widget.playerModel.playType == "Show" ||
//                   widget.playerModel.playType == "Download") {
//                 _setupController(
//                     startAt: Duration(
//                         milliseconds: widget.playerModel.stopTime ?? 0));
//               } else {
//                 _setupController(startAt: Duration.zero);
//               }
//             });
//           }
//         });
//       }
//     } else {
//       if (widget.playerModel.playType == "Video" ||
//           widget.playerModel.playType != "Show") {
//         if (Constant.resolutionsUrls.isNotEmpty) {
//           videoPlayerController = VideoPlayerController.networkUrl(
//             Uri.parse(Constant.resolutionsUrls[0].qualityUrl),
//           );
//         } else {
//           videoPlayerController = VideoPlayerController.networkUrl(
//             Uri.parse(widget.playerModel.videoUrl ?? ""),
//           );
//         }
//       } else {
//         videoPlayerController = VideoPlayerController.networkUrl(
//           Uri.parse(widget.playerModel.videoUrl ?? ""),
//         );
//       }
//       await Future.wait([videoPlayerController.initialize()])
//           .then((value) async {
//         if (mounted) {
//           setState(() {
//             _videoPlayerController = videoPlayerController;
//
//             /* Chewie Controller */
//             if (widget.playerModel.playType == "Video" ||
//                 widget.playerModel.playType == "Show" ||
//                 widget.playerModel.playType == "Download") {
//               _setupController(
//                   startAt:
//                       Duration(milliseconds: widget.playerModel.stopTime ?? 0));
//             } else {
//               _setupController(startAt: Duration.zero);
//             }
//           });
//         }
//       });
//     }
//
//     Future.delayed(Duration.zero).then((value) {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//
//     if (connectivityProvider.isOnline &&
//         (widget.playerModel.playType == "Video" ||
//             widget.playerModel.playType == "Show")) {
//       /* Add Video view */
//       playerProvider.addVideoView(
//           widget.playerModel.videoId.toString(),
//           widget.playerModel.videoType.toString(),
//           widget.playerModel.subVideoType.toString(),
//           widget.playerModel.episodeId.toString());
//     }
//   }
//
//   Future<void> _loadSubtitle() async {
//     if (Constant.subtitleUrls.isNotEmpty) {
//       await playerProvider
//           .setCurrentSubtitle(Constant.subtitleUrls[0].subtitleLang);
//       printLog(
//           "Current subtitleUrl ============> ${Constant.subtitleUrls[0].subtitleUrl}");
//       subtitleController = SubtitleController(
//         subtitleUrl: Constant.subtitleUrls[0].subtitleUrl,
//         subtitleType: SubtitleType.srt,
//         showSubtitles: true,
//       );
//     }
//   }
//
//   _setupController({required Duration startAt}) async {
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       startAt: startAt,
//       autoPlay: true,
//       autoInitialize: true,
//       looping: false,
//       fullScreenByDefault: false,
//       allowFullScreen: true,
//       hideControlsTimer: const Duration(seconds: 1),
//       showControls: true,
//       allowedScreenSleep: false,
//       routePageBuilder: (BuildContext context, Animation<double> animation,
//           Animation<double> secondaryAnimation, Widget child) {
//         return AnimatedBuilder(
//           animation: animation,
//           builder: (BuildContext context, Widget? child) {
//             return Scaffold(
//               body: Center(child: child),
//             );
//           },
//           child: child,
//         );
//       },
//       zoomAndPan: true,
//       transformationController: TransformationController(),
//       additionalOptions: (context) {
//         return <OptionItem>[
//           if (!kIsWeb && Constant.subtitleUrls.isNotEmpty)
//             OptionItem(
//               onTap: () {
//                 setState(() {
//                   subtitlesEnabled = !subtitlesEnabled;
//                 });
//                 if (Navigator.canPop(context)) {
//                   Navigator.pop(context);
//                 }
//                 subtitleDialog();
//               },
//               iconData: Icons.subtitles,
//               title: 'Subtitles',
//             ),
//           if (Constant.resolutionsUrls.isNotEmpty)
//             OptionItem(
//               onTap: () {
//                 if (Navigator.canPop(context)) {
//                   Navigator.pop(context);
//                 }
//                 qualityDialog();
//               },
//               iconData: Icons.video_collection_rounded,
//               title: 'Quality',
//             ),
//         ];
//       },
//       deviceOrientationsOnEnterFullScreen: [
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//       ],
//       deviceOrientationsAfterFullScreen: [
//         (kIsWeb || Constant.isTV)
//             ? DeviceOrientation.landscapeLeft
//             : DeviceOrientation.portraitUp,
//         (kIsWeb || Constant.isTV)
//             ? DeviceOrientation.landscapeRight
//             : DeviceOrientation.portraitDown,
//       ],
//       cupertinoProgressColors: ChewieProgressColors(
//         playedColor: colorPrimary,
//         handleColor: complimentryColor,
//         backgroundColor: grayDark,
//         bufferedColor: white.withOpacity(0.5),
//       ),
//       materialProgressColors: ChewieProgressColors(
//         playedColor: colorPrimary,
//         handleColor: complimentryColor,
//         backgroundColor: grayDark,
//         bufferedColor: white.withOpacity(0.5),
//       ),
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: MyText(
//             color: titleTextColor,
//             text: errorMessage,
//             textalign: TextAlign.center,
//             fontsizeNormal: 14,
//             fontweight: FontWeight.w600,
//             fontsizeWeb: 16,
//             multilanguage: false,
//             maxline: 1,
//             overflow: TextOverflow.ellipsis,
//             fontstyle: FontStyle.normal,
//           ),
//         );
//       },
//     );
//     _videoPlayerController.addListener(() {
//       playerCPosition =
//           (_chewieController?.videoPlayerController.value.position)
//                   ?.inMilliseconds ??
//               0;
//       videoDuration = (_chewieController?.videoPlayerController.value.duration)
//               ?.inMilliseconds ??
//           0;
//       // printLog("playerCPosition :===> $playerCPosition");
//       // printLog("videoDuration :=====> $videoDuration");
//     });
//
//     Future.delayed(Duration.zero).then((value) async {
//       await _chewieController?.play();
//       if (!mounted) return;
//       setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     routeObserver.unsubscribe(this);
//     if (_chewieController != null) {
//       subtitleController?.detach();
//       _chewieController?.removeListener(() {});
//       _chewieController?.videoPlayerController.dispose();
//     }
//     if (!kIsWeb && !Constant.isTV) {
//       if (Platform.isAndroid) {
//         _chromeCastController.stop();
//         _chromeCastController.endSession();
//       }
//       SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     }
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//     playerProvider.clearProvider();
//     resetTimer();
//     super.dispose();
//   }
//
//   void updateSubtitleUrl({required String subtitleUrl}) {
//     printLog("new subtitleUrl ============> $subtitleUrl");
//     if (subtitleController != null) {
//       subtitleController?.updateSubtitleUrl(
//         url: subtitleUrl,
//       );
//     }
//   }
//
//   void updateQualityUrl({
//     required String qualityName,
//     required String qualityUrl,
//   }) async {
//     printLog("new qualityUrl ============> $qualityUrl");
//     printLog("new qualityName ===========> $qualityName");
//     printLog("currentQuality ============> ${playerProvider.currentQuality}");
//     playerCPosition = (_chewieController?.videoPlayerController.value.position)
//             ?.inMilliseconds ??
//         0;
//     videoDuration = (_chewieController?.videoPlayerController.value.duration)
//             ?.inMilliseconds ??
//         0;
//     printLog("playerCPosition ============> $playerCPosition");
//     printLog("videoDuration ==============> $videoDuration");
//
//     if (_chewieController != null &&
//         playerProvider.currentQuality != qualityName) {
//       final videoPlayerController = VideoPlayerController.networkUrl(
//         Uri.parse(qualityUrl),
//       );
//       await Future.wait([videoPlayerController.initialize()])
//           .then((value) async {
//         if (mounted) {
//           await playerProvider.setCurrentQuality(qualityName);
//           _videoPlayerController.dispose();
//           _videoPlayerController = videoPlayerController;
//           _chewieController?.dispose();
//           _setupController(
//               startAt: Duration(milliseconds: playerCPosition ?? 0));
//           Future.delayed(Duration.zero).then((value) {
//             if (!mounted) return;
//             setState(() {});
//           });
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: onBackPressed,
//       child: Scaffold(
//         backgroundColor: black,
//         body: SafeArea(
//           child: _buildPlayerUI(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlayerUI() {
//     return Stack(
//       children: [
//         Center(
//           child: _setBuildPlayer(),
//         ),
//         if (!kIsWeb)
//           Positioned(
//             top: 15,
//             left: 15,
//             child: SafeArea(
//               child: InkWell(
//                 onTap: () {
//                   onBackPressed(false);
//                 },
//                 focusColor: gray.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(20),
//                 child: Utils.buildBackBtnDesign(context),
//               ),
//             ),
//           ),
//         if (!kIsWeb && widget.playerModel.playType != "Download")
//           Positioned(
//             top: 15,
//             right: 15,
//             child: SafeArea(
//               child: Row(
//                 children: [
//                   if (Platform.isIOS)
//                     AirPlayButton(
//                       size: 50,
//                       color: Colors.white,
//                       activeColor: Colors.blue,
//                       onRoutesOpening: () => debugPrint('opening'),
//                       onRoutesClosed: () => debugPrint('closed'),
//                     ),
//                   if (Platform.isAndroid)
//                     ChromeCastButton(
//                       size: 50,
//                       color: Colors.white,
//                       onButtonCreated: _onButtonCreated,
//                       onSessionStarted: _onSessionStarted,
//                       onSessionEnded: () =>
//                           setState(() => _state = AppState.idle),
//                       onRequestCompleted: _onRequestCompleted,
//                       onRequestFailed: _onRequestFailed,
//                     ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _setBuildPlayer() {
//     if (_chewieController != null &&
//         _chewieController?.videoPlayerController.value != null &&
//         _chewieController!.videoPlayerController.value.isInitialized) {
//       if (kIsWeb) {
//         return _buildPlayer();
//       } else {
//         if (subtitleController != null) {
//           printLog("==================== With SUBTITLE ====================");
//           return SubtitleWrapper(
//             videoPlayerController: _chewieController!.videoPlayerController,
//             subtitleController: subtitleController!,
//             subtitleStyle: const SubtitleStyle(
//               textColor: Colors.white,
//               hasBorder: true,
//             ),
//             videoChild: _handleState(),
//           );
//         } else {
//           printLog("================== Without SUBTITLE ==================");
//           return _handleState();
//         }
//       }
//     } else {
//       return _buildLoading();
//     }
//   }
//
//   Widget _buildLoading() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 70,
//           width: 70,
//           child: Utils.pageLoader(),
//         ),
//         const SizedBox(height: 20),
//         MyText(
//           color: titleTextColor,
//           text: loading,
//           textalign: TextAlign.center,
//           fontsizeNormal: 14,
//           fontweight: FontWeight.w600,
//           fontsizeWeb: 16,
//           multilanguage: false,
//           maxline: 1,
//           overflow: TextOverflow.ellipsis,
//           fontstyle: FontStyle.normal,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPlayer() {
//     return AspectRatio(
//       aspectRatio: _chewieController?.aspectRatio ??
//           (_chewieController?.videoPlayerController.value.aspectRatio ??
//               16 / 9),
//       child: Chewie(
//         controller: _chewieController!,
//       ),
//     );
//   }
//
//   playPausePlayer(bool isPlay) async {
//     if (!isPlay) {
//       _chewieController?.pause();
//       _chewieController?.videoPlayerController.pause();
//     } else {
//       _chewieController?.play();
//       _chewieController?.videoPlayerController.play();
//     }
//   }
//
//   Future<void> subtitleDialog() async {
//     await showCupertinoModalPopup<void>(
//       context: context,
//       semanticsDismissible: true,
//       useRootNavigator: true,
//       builder: (context) {
//         return CupertinoActionSheet(
//           actions: Constant.subtitleUrls
//               .map(
//                 (option) => CupertinoActionSheetAction(
//                   onPressed: () async {
//                     await playerProvider
//                         .setCurrentSubtitle(option.subtitleLang);
//                     updateSubtitleUrl(subtitleUrl: option.subtitleUrl);
//                     if (!context.mounted) return;
//                     if (Navigator.canPop(context)) {
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text(
//                     option.subtitleLang,
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: GoogleFonts.inter(
//                       fontSize: 15,
//                       fontStyle: FontStyle.normal,
//                       color: (playerProvider.currentSubtitle ==
//                               option.subtitleLang)
//                           ? black
//                           : black.withOpacity(0.5),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               )
//               .toList(),
//           cancelButton: CupertinoActionSheetAction(
//             onPressed: () => Navigator.pop(context),
//             isDestructiveAction: true,
//             child: Text(
//               "Cancel",
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               style: GoogleFonts.inter(
//                 fontSize: 15,
//                 fontStyle: FontStyle.normal,
//                 color: redColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         );
//       },
//     ).then((value) {
//       printLog("============= SUBTITLE =============");
//       if (!mounted) return;
//       setState(() {});
//     });
//   }
//
//   Future<void> qualityDialog() async {
//     await showCupertinoModalPopup<void>(
//       context: context,
//       semanticsDismissible: true,
//       useRootNavigator: true,
//       builder: (context) {
//         return CupertinoActionSheet(
//           actions: Constant.resolutionsUrls
//               .map(
//                 (option) => CupertinoActionSheetAction(
//                   onPressed: () async {
//                     updateQualityUrl(
//                       qualityName: option.qualityName,
//                       qualityUrl: option.qualityUrl,
//                     );
//                     if (!context.mounted) return;
//                     if (Navigator.canPop(context)) {
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text(
//                     option.qualityName,
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: GoogleFonts.inter(
//                       fontSize: 15,
//                       fontStyle: FontStyle.normal,
//                       color:
//                           (playerProvider.currentQuality == option.qualityName)
//                               ? black
//                               : black.withOpacity(0.5),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               )
//               .toList(),
//           cancelButton: CupertinoActionSheetAction(
//             onPressed: () => Navigator.pop(context),
//             isDestructiveAction: true,
//             child: Text(
//               "Cancel",
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               style: GoogleFonts.inter(
//                 fontSize: 15,
//                 fontStyle: FontStyle.normal,
//                 color: redColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         );
//       },
//     ).then((value) {
//       printLog("============= QUALITY =============");
//       if (!mounted) return;
//       setState(() {});
//     });
//   }
//
//   /* ChromeCast START ********************************** */
//   Widget _handleState() {
//     printLog("_handleState _state ==========> $_state");
//     switch (_state) {
//       case AppState.connected:
//         playPausePlayer(false);
//         return _buildLoading();
//       case AppState.mediaLoaded:
//         playPausePlayer(false);
//         startTimer();
//         return _mediaControls();
//       default:
//         resetTimer();
//         playPausePlayer(true);
//         return _buildPlayer();
//     }
//   }
//
//   Duration? position, duration;
//   Widget _mediaControls() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           MyText(
//             color: descTextColor,
//             text: "playing_cast_device",
//             multilanguage: true,
//             textalign: TextAlign.center,
//             fontsizeNormal: 15,
//             fontsizeWeb: 17,
//             fontweight: FontWeight.w600,
//             maxline: 3,
//             overflow: TextOverflow.ellipsis,
//             fontstyle: FontStyle.normal,
//           ),
//           const SizedBox(height: 20),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: MyNetworkImage(
//               width: Dimens.widthLand,
//               height: Dimens.heightLand,
//               imageUrl: '${_mediaInfo['image']}',
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(height: 20),
//           MyText(
//             color: titleTextColor,
//             text: '${_mediaInfo['title']}',
//             multilanguage: false,
//             textalign: TextAlign.center,
//             fontsizeNormal: 22,
//             fontsizeWeb: 24,
//             fontweight: FontWeight.w700,
//             maxline: 2,
//             overflow: TextOverflow.ellipsis,
//             fontstyle: FontStyle.normal,
//           ),
//           const SizedBox(height: 30),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               _RoundIconButton(
//                 icon: Icons.replay_10,
//                 onPressed: () {
//                   _chromeCastController.seek(relative: true, interval: -10.0);
//                 },
//               ),
//               _RoundIconButton(
//                 icon: _playingOnCasting ? Icons.pause : Icons.play_arrow,
//                 onPressed: _playPause,
//               ),
//               _RoundIconButton(
//                 icon: Icons.forward_10,
//                 onPressed: () {
//                   _chromeCastController.seek(relative: true, interval: 10.0);
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 30),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               MyText(
//                 color: descTextColor,
//                 text: duration2String(position),
//                 multilanguage: false,
//                 textalign: TextAlign.center,
//                 fontsizeNormal: 15,
//                 fontsizeWeb: 17,
//                 fontweight: FontWeight.w600,
//                 maxline: 2,
//                 overflow: TextOverflow.ellipsis,
//                 fontstyle: FontStyle.normal,
//               ),
//               if ((duration?.inMicroseconds ?? 0) > 0) const SizedBox(width: 8),
//               if ((duration?.inMicroseconds ?? 0) > 0)
//                 MyText(
//                   color: descTextColor,
//                   text: "/",
//                   multilanguage: false,
//                   textalign: TextAlign.center,
//                   fontsizeNormal: 15,
//                   fontsizeWeb: 17,
//                   fontweight: FontWeight.w600,
//                   maxline: 2,
//                   overflow: TextOverflow.ellipsis,
//                   fontstyle: FontStyle.normal,
//                 ),
//               const SizedBox(width: 10),
//               MyText(
//                 color: colorAccent,
//                 text: duration2String(duration),
//                 multilanguage: false,
//                 textalign: TextAlign.center,
//                 fontsizeNormal: 15,
//                 fontsizeWeb: 17,
//                 fontweight: FontWeight.w600,
//                 maxline: 2,
//                 overflow: TextOverflow.ellipsis,
//                 fontstyle: FontStyle.normal,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Timer? _timer;
//
//   Future<void> _monitor() async {
//     // monitor cast events
//     var dur = await _chromeCastController.duration(),
//         pos = await _chromeCastController.position();
//     if (duration == null || duration!.inSeconds != dur.inSeconds) {
//       setState(() {
//         duration = dur;
//       });
//     }
//     if (position == null || position!.inSeconds != pos.inSeconds) {
//       setState(() {
//         position = pos;
//       });
//     }
//   }
//
//   void resetTimer() {
//     _timer?.cancel();
//     _timer = null;
//   }
//
//   void startTimer() {
//     if (_timer?.isActive ?? false) {
//       return;
//     }
//     resetTimer();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _monitor();
//     });
//   }
//
//   Future<void> _playPause() async {
//     final playing = await _chromeCastController.isPlaying();
//     if (playing == null) return;
//     if (playing) {
//       await _chromeCastController.pause();
//     } else {
//       await _chromeCastController.play();
//     }
//     setState(() => _playingOnCasting = !playing);
//   }
//
//   Future<void> _onButtonCreated(ChromeCastController controller) async {
//     _chromeCastController = controller;
//     await _chromeCastController.addSessionListener();
//     final isCastConnected = await _chromeCastController.isConnected();
//     final playing = await _chromeCastController.isPlaying();
//     debugPrint("_onButtonCreated isCastConnected ========> $isCastConnected");
//     debugPrint("_onButtonCreated playing ================> $playing");
//     if (isCastConnected != null &&
//         isCastConnected &&
//         playing != null &&
//         playing) {
//       setState(() => _state = AppState.idle);
//       debugPrint("<======== _startNewCasting LOADING... ========>");
//       await _chromeCastController.loadMedia(
//         widget.playerModel.videoUrl ?? '',
//         title: widget.playerModel.videoTitle ?? '',
//         image: widget.playerModel.videoThumb ?? '',
//         live: false,
//       );
//       setState(() => _state = AppState.connected);
//       debugPrint("<======== _startNewCasting STARTED NEXT ========>");
//     }
//   }
//
//   Future<void> _onSessionStarted() async {
//     setState(() => _state = AppState.connected);
//     printLog("_onSessionStarted _state ======> $_state");
//     await _chromeCastController.loadMedia(
//       widget.playerModel.videoUrl ?? '',
//       title: widget.playerModel.videoTitle ?? '',
//       image: widget.playerModel.videoThumb ?? '',
//       live: false,
//     );
//   }
//
//   Future<void> _onRequestCompleted() async {
//     final playing = await _chromeCastController.isPlaying();
//     printLog("_onRequestCompleted playing ======> $playing");
//     if (playing == null) return;
//     final mediaInfo = await _chromeCastController.getMediaInfo();
//     setState(() {
//       _state = AppState.mediaLoaded;
//       _playingOnCasting = playing;
//       if (mediaInfo != null) {
//         _mediaInfo = mediaInfo;
//       }
//     });
//     printLog("_onRequestCompleted _state ======> $_state");
//   }
//
//   Future<void> _onRequestFailed(String? error) async {
//     setState(() => _state = AppState.error);
//     debugPrint("_onRequestFailed =======> $error");
//   }
//   /* ************************************ ChromeCast END */
//
//   Future<void> onBackPressed(didPop) async {
//     if (didPop) return;
//     if (!kIsWeb && !Constant.isTV) {
//       SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     }
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//     printLog("onBackPressed playerCPosition :===> $playerCPosition");
//     printLog("onBackPressed videoDuration :===> $videoDuration");
//     printLog("onBackPressed playType :===> ${widget.playerModel.playType}");
//
//     /* Remove Device from Watch START ********* */
//     if (connectivityProvider.isOnline) {
//       playerProvider.addRemoveDevice(2);
//     }
//     /* *********** Remove Device from Watch END */
//
//     if (widget.playerModel.playType == "Video" ||
//         widget.playerModel.playType == "Show") {
//       if ((playerCPosition ?? 0) > 0) {
//         /* Add to Continue */
//         if (connectivityProvider.isOnline) {
//           await playerProvider.addToContinue(
//               "${widget.playerModel.videoId}",
//               "${widget.playerModel.videoType}",
//               "${widget.playerModel.subVideoType}",
//               "$playerCPosition");
//         }
//         if (!mounted) return;
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context, true);
//         }
//       } else {
//         if (!mounted) return;
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context, false);
//         }
//       }
//     } else {
//       if (!mounted) return;
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context, false);
//       }
//     }
//   }
// }
//
// class _RoundIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onPressed;
//
//   const _RoundIconButton({required this.icon, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialButton(
//       padding: const EdgeInsets.all(16.0),
//       color: colorPrimary,
//       shape: const CircleBorder(),
//       onPressed: onPressed,
//       child: Icon(icon, color: black),
//     );
//   }
// }
//
// enum AppState { idle, connected, mediaLoaded, error }
