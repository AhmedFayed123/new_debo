import 'dart:io';

import 'package:debo/pages/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../provider/bottombarprovider.dart';
import '../provider/generalprovider.dart';
import '../provider/homeprovider.dart';
import '../provider/sectiondataprovider.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/strings.dart';
import '../utils/utils.dart';
import '../widget/myimage.dart';
import '../widget/mytext.dart';
import 'forgot_password_screen.dart';
import 'otpverify.dart';

class LoginSocial extends StatefulWidget {
  const LoginSocial({super.key});

  @override
  State<LoginSocial> createState() => LoginSocialState();
}

class LoginSocialState extends State<LoginSocial> {
  late GeneralProvider generalProvider;

  final numberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? mobileNumber,
      email,
      userName,
      strType,
      strDeviceType,
      strDeviceToken,
      strPrivacyAndTNC;
  File? mProfileImg;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userEmail = "";

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
    _getDeviceToken();
    _getData();
  }

  _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
      } else {
        strDeviceType = "2";
      }
      strDeviceToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>strDeviceType $strDeviceType");
  }

  _getData() async {
    String? privacyUrl, termsConditionUrl;
    await generalProvider.getPages();
    if (!generalProvider.loading) {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        if ((generalProvider.pagesModel.result?.length ?? 0) > 0) {
          for (var i = 0;
          i < (generalProvider.pagesModel.result?.length ?? 0);
          i++) {
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("privacy")) {
              privacyUrl = generalProvider.pagesModel.result?[i].url;
            }
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("terms")) {
              termsConditionUrl = generalProvider.pagesModel.result?[i].url;
            }
          }
        }
      }
    }
    printLog('privacyUrl ==> $privacyUrl');
    printLog('termsConditionUrl ==> $termsConditionUrl');

    strPrivacyAndTNC = await Utils.getPrivacyTandCText(
        privacyUrl ?? "", termsConditionUrl ?? "");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    numberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 170,
                      height: 60,
                      alignment: Alignment.centerLeft,
                      child: MyImage(
                        fit: BoxFit.fill,
                        imagePath: "appicon.png",
                      ),
                    ),
                    const SizedBox(height: 25),
                    MyText(
                      color: titleTextColor,
                      text: "welcomeback",
                      fontsizeNormal: 20,
                      fontsizeWeb: 25,
                      multilanguage: true,
                      fontweight: FontWeight.bold,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 7),
                    // MyText(
                    //   color: descTextColor,
                    //   text: "login_with_mobile_note",
                    //   fontsizeNormal: 14,
                    //   fontsizeWeb: 15,
                    //   multilanguage: true,
                    //   fontweight: FontWeight.w500,
                    //   maxline: 2,
                    //   overflow: TextOverflow.ellipsis,
                    //   textalign: TextAlign.center,
                    //   fontstyle: FontStyle.normal,
                    // ),
                    // const SizedBox(height: 30),

                    // Email Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "email",
                        labelStyle: TextStyle(color: descTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: colorPrimary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: colorPrimary),
                        ),
                        filled: true,
                        fillColor: edtViewShadowColor,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: white),
                    ),
                    const SizedBox(height: 15),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "password",
                        labelStyle: TextStyle(color: descTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: colorPrimary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: colorPrimary),
                        ),
                        filled: true,
                        fillColor: edtViewShadowColor,
                      ),
                      obscureText: true,
                      style: TextStyle(color: white),
                    ),
                    const SizedBox(height: 20),

                    /* Login Button */
                    InkWell(
                      onTap: () async {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          Utils.showSnackbar(
                              context, "info", "fill_all_fields", true);
                          return;
                        }
                        await _performEmailLogin(
                            emailController.text, passwordController.text);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 52,
                        decoration: Utils.setGradLTRBGWithBorder(
                            colorPrimary, colorPrimaryDark, transparent, 30, 0),
                        alignment: Alignment.center,
                        child: MyText(
                          color: white,
                          text: "login",
                          multilanguage: true,
                          fontsizeNormal: 17,
                          fontsizeWeb: 19,
                          fontweight: FontWeight.w700,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
// After the login button in your build method
                    const SizedBox(height: 10),

// Forgot Password Text
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          _navigateToForgotPassword();
                        },
                        child: MyText(
                          color: colorPrimary,
                          text: "forgot_password",
                          fontsizeNormal: 14,
                          fontsizeWeb: 16,
                          multilanguage: true,
                          fontweight: FontWeight.w600,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.end,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

// Don't have an account? Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          color: descTextColor,
                          text: "dont_have_account",
                          fontsizeNormal: 14,
                          fontsizeWeb: 16,
                          multilanguage: true,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            _navigateToSignUp();
                          },
                          child: MyText(
                            color: colorPrimary,
                            text: "sign_up",
                            fontsizeNormal: 14,
                            fontsizeWeb: 16,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                    /* Privacy & TermsCondition link */
                    if (strPrivacyAndTNC != null)
                      Utils.htmlTexts(strPrivacyAndTNC),
                    const SizedBox(height: 10),

                    /* Or */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 1,
                          color: colorAccent,
                        ),
                        const SizedBox(width: 15),
                        MyText(
                          color: descTextColor,
                          text: "or",
                          multilanguage: true,
                          fontsizeNormal: 14,
                          fontsizeWeb: 16,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 15),
                        Container(
                          width: 80,
                          height: 1,
                          color: colorAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    /* Google Login Button */
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          printLog("Clicked on : ====> loginWith Google");
                          _gmailLogin();
                        },
                        borderRadius: BorderRadius.circular(26),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyImage(
                              width: 30,
                              height: 30,
                              imagePath: "ic_google.png",
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 30),
                            MyText(
                              color: black,
                              text: "loginwithgoogle",
                              fontsizeNormal: 14,
                              fontsizeWeb: 16,
                              multilanguage: true,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      ),
                    ),

                    /* Apple Login Button */
                    if (Platform.isIOS)
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 52,
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            printLog("Clicked on : ====> loginWith Apple");
                            signInWithApple();
                          },
                          borderRadius: BorderRadius.circular(26),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyImage(
                                width: 30,
                                height: 30,
                                imagePath: "ic_apple.png",
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 30),
                              MyText(
                                color: black,
                                text: "loginwithapple",
                                fontsizeNormal: 14,
                                fontsizeWeb: 16,
                                multilanguage: true,
                                fontweight: FontWeight.w600,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: MyImage(
                    fit: BoxFit.contain,
                    imagePath: "ic_close.png",
                    color: defaultIconColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordScreen(),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpScreen(),
      ),
    );
  }
  Future<void> _performEmailLogin(String email, String password) async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
    Provider.of<SectionDataProvider>(context, listen: false);
    final bottombarProvider =
    Provider.of<BottombarProvider>(context, listen: false);

    Utils.showProgress(context);

    await generalProvider.loginNormal(
        email,
        password,
        Constant.deviceName,
        strDeviceType,
        strDeviceToken);

    if (!generalProvider.loading) {
      if (generalProvider.loginNormalModel.status == 200) {
        Utils.saveUserCreds(
          userID: generalProvider.loginNormalModel.result?[0].id.toString(),
          fullName:
          generalProvider.loginNormalModel.result?[0].fullName.toString(),
          userName:
          generalProvider.loginNormalModel.result?[0].userName.toString(),
          userEmail:
          generalProvider.loginNormalModel.result?[0].email.toString(),
          userMobile: generalProvider.loginNormalModel.result?[0].mobileNumber
              .toString(),
          userImage:
          generalProvider.loginNormalModel.result?[0].image.toString(),
          userPremium:
          generalProvider.loginNormalModel.result?[0].isBuy.toString(),
          userType: generalProvider.loginNormalModel.result?[0].type.toString(),
          deviceType:
          generalProvider.loginNormalModel.result?[0].deviceType.toString(),
          deviceToken: generalProvider.loginNormalModel.result?[0].deviceToken
              .toString(),
        );

        Constant.userID =
            generalProvider.loginNormalModel.result?[0].id.toString();

        await bottombarProvider.setBottomNavIndex(0);
        await bottombarProvider.setAppbarVisibility(true);
        await homeProvider.setLoading(true);
        await sectionDataProvider.getSectionBanner("0", "1");
        await sectionDataProvider.getSectionList("0", "1", 1);

        await Utils.initializeHiveBoxes();

        if (!mounted) return;
        Utils.hideProgress();
        if (!mounted) return;
        Utils.redirectToMainPage(context: context);
      } else {
        if (!mounted) return;
        Utils.hideProgress();
        Utils.showSnackbar(context, "fail",
            "${generalProvider.loginNormalModel.message}", false);
      }
    }
  }

  /* Google Login */
  Future<void> _gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    printLog('GoogleSignIn ===> id : ${user.id}');
    printLog('GoogleSignIn ===> email : ${user.email}');
    printLog('GoogleSignIn ===> displayName : ${user.displayName}');
    printLog('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

    if (!mounted) return;
    Utils.showProgress(context);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
      await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      if (!mounted) return;
      Utils.showProgress(context);

      userCredential = await _auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      printLog("UserName ========> ${user.displayName}");
      printLog("UserEmail =======> ${user.email}");
      printLog("UserPhotoUrl ====> ${user.photoUrl}");
      String firebasedid = userCredential.user?.uid ?? "";
      printLog('firebasedid :===> $firebasedid');

      /* Save PhotoUrl in File */
      mProfileImg = await Utils.saveImageInStorage(user.photoUrl ?? "");
      printLog('mProfileImg :===> $mProfileImg');

      checkAndNavigate(user.email, user.displayName ?? "", "2");
    } on FirebaseAuthException catch (e) {
      printLog('===>Exp${e.code.toString()}');
      printLog('===>Exp${e.message.toString()}');
      if (!mounted) return;
      Utils.hideProgress();
      if (e.code.toString() == "user-not-found") {
      } else if (e.code == 'wrong-password') {
        printLog('Wrong password provided.');
        Utils.showToast('Wrong password provided.');
      }
    }
  }

  /* Apple Login */
  Future<void> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = Utils.sha256ofString(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      if (!mounted) return;
      Utils.showProgress(context);

      final authResult = await _auth.signInWithCredential(oauthCredential);

      String? displayName;
      final firebaseUser = authResult.user;
      dynamic firebasedId;

      if (appleCredential.givenName != null) {
        displayName =
        '${appleCredential.givenName} ${appleCredential.familyName}';
        userEmail = authResult.user?.email.toString() ?? "";
        await firebaseUser?.updateDisplayName(displayName);
      } else {
        userEmail = firebaseUser?.email.toString() ?? "";
        firebasedId = firebaseUser?.uid.toString();
        displayName = firebaseUser?.displayName.toString();
      }

      checkAndNavigate(
          userEmail,
          ((displayName ?? "").contains("null")) ? "" : (displayName ?? ""),
          "3");
    } catch (exception) {
      printLog("Apple Login exception =====> $exception");
      if (!mounted) return;
      Utils.hideProgress();
    }
  }

  checkAndNavigate(String mail, String displayName, String type) async {
    email = mail;
    userName = displayName;
    strType = type;

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
    Provider.of<SectionDataProvider>(context, listen: false);
    final bottombarProvider =
    Provider.of<BottombarProvider>(context, listen: false);
    await generalProvider.loginWithSocial(email, userName, strType,
        Constant.deviceName, strDeviceType, strDeviceToken, mProfileImg);

    if (!generalProvider.loading) {
      if (generalProvider.loginSocialModel.status == 200) {
        Utils.saveUserCreds(
          userID: generalProvider.loginSocialModel.result?[0].id.toString(),
          fullName:
          generalProvider.loginSocialModel.result?[0].fullName.toString(),
          userName:
          generalProvider.loginSocialModel.result?[0].userName.toString(),
          userEmail:
          generalProvider.loginSocialModel.result?[0].email.toString(),
          userMobile: generalProvider.loginSocialModel.result?[0].mobileNumber
              .toString(),
          userImage:
          generalProvider.loginSocialModel.result?[0].image.toString(),
          userPremium:
          generalProvider.loginSocialModel.result?[0].isBuy.toString(),
          userType: generalProvider.loginSocialModel.result?[0].type.toString(),
          deviceType:
          generalProvider.loginSocialModel.result?[0].deviceType.toString(),
          deviceToken: generalProvider.loginSocialModel.result?[0].deviceToken
              .toString(),
        );

        Constant.userID =
            generalProvider.loginSocialModel.result?[0].id.toString();

        await bottombarProvider.setBottomNavIndex(0);
        await bottombarProvider.setAppbarVisibility(true);
        await homeProvider.setLoading(true);
        await sectionDataProvider.getSectionBanner("0", "1");
        await sectionDataProvider.getSectionList("0", "1", 1);

        await Utils.initializeHiveBoxes();

        if (!mounted) return;
        Utils.hideProgress();
        if (!mounted) return;
        Utils.redirectToMainPage(context: context);
      } else {
        if (!mounted) return;
        Utils.hideProgress();
        Utils.showSnackbar(context, "fail",
            "${generalProvider.loginSocialModel.message}", false);
      }
    }
  }
}