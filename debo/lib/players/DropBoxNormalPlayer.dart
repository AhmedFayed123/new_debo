



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';


class DropBoxNormalPlayer extends StatefulWidget {
  const DropBoxNormalPlayer({super.key, required this.url});
  final String url;

  @override
  State<DropBoxNormalPlayer> createState() => _DropBoxNormalPlayerState();
}

class _DropBoxNormalPlayerState extends State<DropBoxNormalPlayer>{
  bool loading = true;
  late WebViewController  controller ;

  @override
  void initState() {

    getLink();

    super.initState();
  }


  @override
  void dispose() async{
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }



  getLink()async{
    String link =widget.url;

    print(link);
    WebViewCookie cookie =
    const WebViewCookie(
        name: "dummy_name",
        value: "dummy_value",
        domain: "example.com");
    WebViewCookieManager().setCookie(cookie);
    controller
    = WebViewController()
      ..setUserAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36")
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      ..setBackgroundColor(const Color(0x00000000))

      ..setNavigationDelegate(

        NavigationDelegate(
          onProgress: (int progress) {
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async{

            try {


              await controller.runJavaScript(
                  "document.querySelector('button[aria-label=\"Full screen\"]').click()");
              await controller.runJavaScript(
                  "document.querySelector('button[aria-label=\"Exit full screen\"]').remove()").then((value) {
                print("6666666666666666666666666666666666");
                Future.delayed(Duration(seconds: 2), () async{

                  setState(() {
                    loading=false;
                  });
                  controller.runJavaScript(
                      "document.querySelector('._titleBarWrapper_10wwt_31').remove()");
                  controller.runJavaScript("document.getElementById('ccpa-iframe').remove()");

                  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeLeft]);


                });
              });
            }catch (e){
              debugPrint("runJavaScript erorr $e");
            }


          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            print("NavigationRequest ${request.url}");
            return NavigationDecision.prevent;


          },
        ),
      )
      ..loadRequest(Uri.parse(link));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:
      loading?Center(child: CircularProgressIndicator()): WebViewWidget(controller: controller),
    );
  }

}
