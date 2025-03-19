
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/profileprovider.dart';
import '../utils/color.dart';
import '../utils/sharedpre.dart';
import '../utils/utils.dart';
import '../widget/myimage.dart';
import '../widget/mytext.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  SharedPre sharedPref = SharedPre();
  late ProfileProvider profileProvider;

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    super.initState();
  }

  _getData() async {
    if (!mounted) return;
    profileProvider.getProfile(context);
    profileProvider.getDeviceSyncList();

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBarWithOnlyActions(context),
      body: SafeArea(
        child: _buildPage(),
      ),
    );
  }

  Widget _buildPage() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(13, 0, 13, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* AppIcon */
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(5),
                child: MyImage(
                  height: 30,
                  imagePath: "appicon.png",
                  fit: BoxFit.contain,
                ),
              ),

              /* Current Plan Details */
              Container(
                margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    await Utils.openSubscription(context: context, oldPage: "");
                  },
                  child: MyText(
                    color: titleTextColor,
                    text: (profileProvider.profileModel.result != null &&
                            (profileProvider.profileModel.result?.length ?? 0) >
                                0)
                        ? (((profileProvider.profileModel.result?[0].isBuy ??
                                    0) ==
                                1)
                            ? (profileProvider
                                    .profileModel.result?[0].packageName ??
                                "")
                            : "View All Plan")
                        : "View All Plan",
                    multilanguage: false,
                    textalign: TextAlign.center,
                    fontsizeNormal: 20,
                    fontsizeWeb: 23,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                    withShaderMask: true,
                  ),
                ),
              ),
              /* Plan Expire (in days) */
              Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: MyText(
                  color: descTextColor,
                  text: (profileProvider.profileModel.result != null &&
                          (profileProvider.profileModel.result?.length ?? 0) >
                              0)
                      ? (((profileProvider.profileModel.result?[0].isBuy ??
                                      0) ==
                                  1 &&
                              (profileProvider
                                          .profileModel.result?[0].expiryDate ??
                                      "")
                                  .isNotEmpty)
                          ? "Plan expires in ${Utils.remainTimeInDays((profileProvider.profileModel.result?[0].expiryDate ?? ""))} days"
                          : "Buy subscription & get more")
                      : "Buy subscription & get more",
                  multilanguage: false,
                  textalign: TextAlign.center,
                  fontsizeNormal: 12,
                  fontsizeWeb: 15,
                  fontweight: FontWeight.w400,
                  maxline: 2,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                  withShaderMask: false,
                ),
              ),
              _buildLine(0, 18, 0, 18),

              /* Mobile Number / Email Address */
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: MyText(
                  color: titleTextColor,
                  text: (profileProvider.profileModel.result == null ||
                          (profileProvider.profileModel.result?.length ?? 0) ==
                              0)
                      ? "-"
                      : (Utils.convertToStar(
                          (profileProvider.profileModel.result?[0].type == 1)
                              ? (profileProvider
                                      .profileModel.result?[0].mobileNumber ??
                                  "")
                              : ((profileProvider
                                              .profileModel.result?[0].email ??
                                          "")
                                      .isNotEmpty
                                  ? (profileProvider
                                          .profileModel.result?[0].email ??
                                      "")
                                  : "-"))),
                  multilanguage: false,
                  textalign: TextAlign.center,
                  fontsizeNormal: 16,
                  fontsizeWeb: 18,
                  fontweight: FontWeight.w500,
                  maxline: 2,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                  withShaderMask: false,
                ),
              ),
              if (profileProvider.profileModel.result != null &&
                  (profileProvider.profileModel.result?.length ?? 0) > 0)
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: MyText(
                    color: titleTextColor,
                    text: (profileProvider.profileModel.result?[0].type == 1)
                        ? "registered_mobile_number"
                        : ((profileProvider.profileModel.result?[0].email ?? "")
                                .isNotEmpty
                            ? "registered_email"
                            : "dash_symbol"),
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: 12,
                    fontsizeWeb: 15,
                    fontweight: FontWeight.w400,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                    withShaderMask: false,
                  ),
                ),

              /* All Devices */
              _buildDeviceList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceList() {
    return Container(
      decoration: Utils.setBackground(secondaryBgColor, 10),
      margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
      padding: const EdgeInsets.fromLTRB(13, 15, 13, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            color: titleTextColor,
            text: "all_devices",
            multilanguage: true,
            textalign: TextAlign.center,
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            fontweight: FontWeight.w600,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
            withShaderMask: false,
          ),
          const SizedBox(height: 15),
          AlignedGridView.count(
            shrinkWrap: true,
            crossAxisCount: 1,
            crossAxisSpacing: 27,
            mainAxisSpacing: 27,
            itemCount: (profileProvider.deviceSyncModel.result?.length ?? 0),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int position) {
              return Material(
                type: MaterialType.transparency,
                child: _buildDeviceItem(position: position),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem({required int position}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /* Device Icon */
        Container(
          height: 25,
          width: 25,
          alignment: Alignment.center,
          child: MyImage(
            imagePath: _setIconByType(position: position),
            fit: BoxFit.contain,
            color: defaultIconColor,
          ),
        ),
        const SizedBox(width: 15),

        /* Device Name */
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                color: titleTextColor,
                text: profileProvider
                        .deviceSyncModel.result?[position].deviceName ??
                    "-",
                multilanguage: false,
                textalign: TextAlign.start,
                fontsizeNormal: 12,
                fontsizeWeb: 15,
                fontweight: FontWeight.w600,
                maxline: 2,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
                withShaderMask: false,
              ),
              const SizedBox(height: 5),
              MyText(
                color: descTextColor,
                text: (profileProvider
                                .deviceSyncModel.result?[position].createdAt !=
                            null &&
                        (profileProvider.deviceSyncModel.result?[position]
                                    .createdAt ??
                                "")
                            .isNotEmpty)
                    ? ("Last used : ${DateFormat("dd MMM, yyyy").format(DateTime.parse(profileProvider.deviceSyncModel.result?[position].createdAt ?? ""))}")
                    : "-",
                multilanguage: false,
                textalign: TextAlign.start,
                fontsizeNormal: 12,
                fontsizeWeb: 15,
                fontweight: FontWeight.w400,
                maxline: 2,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
                withShaderMask: false,
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),

        /* Logout Button */
        InkWell(
          onTap: () async {
            await Utils.logoutFromApp(
              context,
              profileProvider.deviceSyncModel.result?[position].id ?? 0,
              profileProvider.deviceSyncModel.result?[position].deviceType ?? 0,
              profileProvider.deviceSyncModel.result?[position].deviceToken ??
                  "",
              profileProvider.deviceSyncModel.result?[position].deviceId ?? "",
            );
            _getData();
          },
          child: Container(
            height: 32,
            alignment: Alignment.center,
            decoration: Utils.setBackground(lightBlack.withOpacity(0.3), 5),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: MyText(
              color: white,
              text: "log_out",
              multilanguage: true,
              textalign: TextAlign.start,
              fontsizeNormal: 13,
              fontsizeWeb: 15,
              fontweight: FontWeight.w600,
              maxline: 2,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
              withShaderMask: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLine(double leftMargin, double topMargin, double rightMargin,
      double bottomMargin) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.7,
      margin:
          EdgeInsets.fromLTRB(leftMargin, topMargin, rightMargin, bottomMargin),
      decoration: Utils.setBackground(gray.withOpacity(0.3), 0.7),
    );
  }

  String _setIconByType({required int position}) {
    String icon = "";
    if (profileProvider.deviceSyncModel.result?[position].deviceType == 2) {
      icon = "ic_iphone.png";
    } else if (profileProvider.deviceSyncModel.result?[position].deviceType ==
        3) {
      icon = "ic_web.png";
    } else if (profileProvider.deviceSyncModel.result?[position].deviceType ==
        4) {
      icon = "ic_tv.png";
    } else {
      icon = "ic_phone.png";
    }
    return icon;
  }
}
