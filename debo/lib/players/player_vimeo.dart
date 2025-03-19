
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';

import '../model/playermodel.dart';
import '../provider/connectivityprovider.dart';
import '../provider/playerprovider.dart';
import '../routes/routes_constant.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';

class PlayerVimeo extends StatefulWidget {
  final PlayerModel playerModel;
  const PlayerVimeo({
    super.key,
    required this.playerModel,
  });

  @override
  State<PlayerVimeo> createState() => PlayerVimeoState();
}

class PlayerVimeoState extends State<PlayerVimeo>
    with RouteAware, WidgetsBindingObserver {
  String? vUrl;
  late PlayerProvider playerProvider;
  late ConnectivityProvider connectivityProvider;
  int? playerCPosition, videoDuration;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    printLog('didChangeAppLifecycleState state =====> ${state.name}');
    switch (state) {
      case AppLifecycleState.resumed:
        if (connectivityProvider.isOnline) {
          playerProvider.addRemoveDevice(1);
        }
        break;
      case AppLifecycleState.paused:
        if (connectivityProvider.isOnline) {
          playerProvider.addRemoveDevice(2);
        }
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);
    super.initState();
    _playerInit();
  }

  _playerInit() async {
    WidgetsFlutterBinding.ensureInitialized();

    /* ******* Check Device Sync ******* */
    if (connectivityProvider.isOnline &&
        (widget.playerModel.playType == "Video" ||
            widget.playerModel.playType == "Show")) {
      await playerProvider.addRemoveDevice(1);
      if (!playerProvider.isDeviceAdded) {
        if (!mounted) return;
        dynamic isNotWatching = await Utils.openWebDialog(
          context: context,
          newPage: RoutesConstant.cannotWatchPage,
          oldPage: "",
          reqText: "",
        );
        printLog("isNotWatching =========> $isNotWatching");
        if (!mounted) return;
        if (isNotWatching != null && isNotWatching == false) {
          if (kIsWeb) {
            if (context.canPop()) {
              context.pop(false);
            }
          } else {
            if (Navigator.canPop(context)) {
              Navigator.pop(context, false);
            }
          }
          return;
        }
      }
    }
    /* ************** */

    vUrl = widget.playerModel.videoUrl;
    if (!(vUrl ?? "").contains("https://vimeo.com/")) {
      vUrl = "https://vimeo.com/$vUrl";
    }
    printLog("vUrl===> $vUrl");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });

    if (widget.playerModel.playType == "Video" ||
        widget.playerModel.playType != "Show") {
      /* Add Video view */
      await playerProvider.addVideoView(
          widget.playerModel.videoId.toString(),
          widget.playerModel.videoType.toString(),
          widget.playerModel.subVideoType.toString(),
          widget.playerModel.episodeId.toString());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!kIsWeb && !Constant.isTV) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: Scaffold(
        backgroundColor: black,
        body: SafeArea(
          child: _buildPlayerUI(),
        ),
      ),
    );
  }

  Widget _buildPlayerUI() {
    return Stack(
      children: [
        VimeoVideoPlayer(
          url: vUrl ?? "",
          autoPlay: true,
          systemUiOverlay: const [],
          deviceOrientation: const [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
          startAt: Duration(milliseconds: widget.playerModel.stopTime ?? 0),
          onProgress: (timePoint) {
            playerCPosition = timePoint.inMilliseconds;
            printLog("playerCPosition :===> $playerCPosition");
          },
          onFinished: () async {
            /* Remove From Continue */
            await playerProvider.removeFromContinue(
                "${widget.playerModel.videoId}",
                "${widget.playerModel.videoType}",
                "${widget.playerModel.subVideoType}");
          },
        ),
        if (!kIsWeb)
          Positioned(
            top: 15,
            left: 15,
            child: SafeArea(
              child: InkWell(
                onTap: () {
                  onBackPressed(false);
                },
                focusColor: gray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                child: Utils.buildBackBtnDesign(context),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (!kIsWeb && !Constant.isTV) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    printLog("onBackPressed playerCPosition :===> $playerCPosition");
    printLog("onBackPressed videoDuration :===> $videoDuration");
    printLog("onBackPressed playType :===> ${widget.playerModel.playType}");

    /* Remove Device from Watch START ********* */
    if (connectivityProvider.isOnline) {
      playerProvider.addRemoveDevice(2);
    }
    /* *********** Remove Device from Watch END */

    if (widget.playerModel.playType == "Video" ||
        widget.playerModel.playType == "Show") {
      if ((playerCPosition ?? 0) > 0) {
        /* Add to Continue */
        if (connectivityProvider.isOnline) {
          await playerProvider.addToContinue(
              "${widget.playerModel.videoId}",
              "${widget.playerModel.videoType}",
              "${widget.playerModel.subVideoType}",
              "$playerCPosition");
        }
        if (!mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      } else {
        if (!mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context, false);
        }
      }
    } else {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, false);
      }
    }
  }
}
