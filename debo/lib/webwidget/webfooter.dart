
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../provider/generalprovider.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/sharedpre.dart';
import '../utils/utils.dart';
import '../web_js/js_helper_mobile.dart';
import '../widget/myimage.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import 'interactive_icon.dart';
import 'interactive_text.dart';

class WebFooter extends StatefulWidget {
  final String? newPage, oldPage;
  final dynamic reqText;
  const WebFooter({
    super.key,
    required this.newPage,
    required this.oldPage,
    required this.reqText,
  });

  @override
  State<WebFooter> createState() => _WebFooterState();
}

class _WebFooterState extends State<WebFooter> {
  final JSHelper _jsHelper = JSHelper();
  SharedPre sharedPref = SharedPre();
  late GeneralProvider generalProvider;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  _redirectToUrl(loadingUrl, bool openInNew) async {
    printLog("loadingUrl -----------> $loadingUrl");
    printLog("openInNew ------------> $openInNew");
    /*
      _blank => open new Tab
      _self => open in current Tab
    */
    String dataFromJS;
    if (openInNew) {
      dataFromJS = await _jsHelper.callOpenTab(loadingUrl, '_blank');
    } else {
      dataFromJS = await _jsHelper.callOpenTab(loadingUrl, '_self');
    }
    printLog("dataFromJS -----------> $dataFromJS");
  }

  _getData() async {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);

    await generalProvider.getPages();
    await generalProvider.getSocialLinks();

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
      child: (MediaQuery.of(context).size.width < 800)
          ? _buildColumnFooter()
          : _buildRowFooter(),
    );
  }

  Widget _buildRowFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* App Icon & Desc. */
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 40,
                alignment: Alignment.centerLeft,
                child: MyImage(
                  fit: BoxFit.contain,
                  imagePath: "appicon.png",
                ),
              ),
              const SizedBox(height: 8),
              Consumer<GeneralProvider>(
                builder: (context, generalProvider, child) {
                  return MyText(
                    color: descTextColor,
                    multilanguage: false,
                    text: generalProvider.appDescription ?? "",
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 13,
                    fontsizeNormal: 13,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                    maxline: 5,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 30),

        /* Quick Links */
        Expanded(
          child: _buildPages(),
        ),
        const SizedBox(width: 30),

        /* Contact With us & Available On */
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Social Icons */
              _buildSocialLink(),
              const SizedBox(height: 20),

              /* Available On */
              MyText(
                color: titleTextColor,
                multilanguage: false,
                text: "${Constant.appName} Available On",
                fontweight: FontWeight.w600,
                fontsizeWeb: 13,
                fontsizeNormal: 13,
                textalign: TextAlign.start,
                fontstyle: FontStyle.normal,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              /* Store Icons */
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _redirectToUrl(Constant.androidAppUrl, true);
                    },
                    borderRadius: BorderRadius.circular(3),
                    child: InteractiveIcon(builder: (isHovered) {
                      return SizedBox(
                        height: Dimens.heightSocialBtn,
                        width: Dimens.widthSocialBtn,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          child: MyImage(
                            imagePath: "playstore.png",
                            height: 25,
                            width: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      _redirectToUrl(Constant.iosAppUrl, true);
                    },
                    borderRadius: BorderRadius.circular(3),
                    child: InteractiveIcon(builder: (isHovered) {
                      return SizedBox(
                        height: Dimens.heightSocialBtn,
                        width: Dimens.widthSocialBtn,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          child: MyImage(
                            imagePath: "applestore.png",
                            height: 25,
                            width: 25,
                            fit: BoxFit.contain,
                            color: white,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumnFooter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* App Icon & Desc. */
        Container(
          width: 120,
          height: 40,
          alignment: Alignment.centerLeft,
          child: MyImage(
            fit: BoxFit.contain,
            imagePath: "appicon.png",
          ),
        ),
        const SizedBox(height: 8),
        Consumer<GeneralProvider>(
          builder: (context, generalProvider, child) {
            return MyText(
              color: descTextColor,
              multilanguage: false,
              text: generalProvider.appDescription ?? "",
              fontweight: FontWeight.w500,
              fontsizeWeb: 13,
              fontsizeNormal: 13,
              textalign: TextAlign.start,
              fontstyle: FontStyle.normal,
              maxline: 5,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        const SizedBox(height: 30),

        /* Quick Links */
        _buildPages(),
        const SizedBox(height: 30),

        /* Contact With us & Store Icons */
        /* Social Icons */
        _buildSocialLink(),
        const SizedBox(height: 20),

        /* Available On */
        MyText(
          color: titleTextColor,
          multilanguage: false,
          text: "${Constant.appName} Available On",
          fontweight: FontWeight.w600,
          fontsizeWeb: 13,
          fontsizeNormal: 13,
          textalign: TextAlign.start,
          fontstyle: FontStyle.normal,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        /* Store Icons */
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                _redirectToUrl(Constant.androidAppUrl, true);
              },
              borderRadius: BorderRadius.circular(3),
              child: InteractiveIcon(builder: (isHovered) {
                return SizedBox(
                  height: Dimens.heightSocialBtn,
                  width: Dimens.widthSocialBtn,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    child: MyImage(
                      imagePath: "playstore.png",
                      height: 25,
                      width: 25,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 15),
            InkWell(
              onTap: () {
                _redirectToUrl(Constant.iosAppUrl, true);
              },
              borderRadius: BorderRadius.circular(3),
              child: InteractiveIcon(builder: (isHovered) {
                return SizedBox(
                  height: Dimens.heightSocialBtn,
                  width: Dimens.widthSocialBtn,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    child: MyImage(
                      imagePath: "applestore.png",
                      height: 25,
                      width: 25,
                      fit: BoxFit.contain,
                      color: white,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPages() {
    if (generalProvider.loading) {
      return const SizedBox.shrink();
    } else {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          itemCount: (generalProvider.pagesModel.result?.length ?? 0),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int position) {
            return _buildPageItem(
              pageName:
                  generalProvider.pagesModel.result?[position].title ?? "",
              onClick: () {
                // context.pushNamed(
                //   RoutesConstant.aboutPrivacyTermsPage,
                //   extra: {
                //     'newpage': widget.newPage,
                //     'title':
                //         generalProvider.pagesModel.result?[position].title ??
                //             "",
                //     'url':
                //         generalProvider.pagesModel.result?[position].url ?? "",
                //   },
                // );
                _redirectToUrl(
                    generalProvider.pagesModel.result?[position].url ?? "",
                    false);
              },
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildPageItem({
    required String pageName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: InteractiveText(builder: (isHovered) {
        return MyText(
          multilanguage: false,
          color: (isHovered ? colorAccent : white),
          text: pageName,
          maxline: 2,
          textalign: TextAlign.justify,
          fontstyle: FontStyle.normal,
          fontsizeNormal: 12,
          fontsizeWeb: 14,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w600,
          withShaderMask: false,
        );
      }),
    );
  }

  Widget _buildSocialLink() {
    if (generalProvider.loading) {
      return const SizedBox.shrink();
    } else {
      if (generalProvider.socialLinkModel.status == 200 &&
          generalProvider.socialLinkModel.result != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              color: titleTextColor,
              multilanguage: false,
              text: "Connect With Us",
              fontweight: FontWeight.w600,
              fontsizeWeb: 13,
              fontsizeNormal: 13,
              textalign: TextAlign.start,
              fontstyle: FontStyle.normal,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            AlignedGridView.count(
              shrinkWrap: true,
              crossAxisCount: 6,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              itemCount: (generalProvider.socialLinkModel.result?.length ?? 0),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int position) {
                return Wrap(
                  children: [
                    _buildSocialIcon(
                      iconUrl: generalProvider
                              .socialLinkModel.result?[position].image ??
                          "",
                      onClick: () {
                        _redirectToUrl(
                            generalProvider
                                    .socialLinkModel.result?[position].url ??
                                "",
                            true);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildSocialIcon({
    required String iconUrl,
    required Function() onClick,
  }) {
    return SizedBox(
      height: Dimens.heightSocialBtn,
      width: Dimens.widthSocialBtn,
      child: InkWell(
        borderRadius: BorderRadius.circular(3.0),
        onTap: onClick,
        child: InteractiveIcon(builder: (isHovered) {
          return Container(
            decoration:
                Utils.setBackground(isHovered ? colorPrimary : lightBlack, 25),
            padding: const EdgeInsets.all(2),
            child: MyNetworkImage(
              imageUrl: iconUrl,
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
          );
        }),
      ),
    );
  }
}
