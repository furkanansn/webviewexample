import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class Beginning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Image.network(
                      "http://hobedtech.com/wp-content/uploads/2020/03/cropped-unnamed-e1583272353489.png",
                      width: 100,
                    ),
                    onTap: () => Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) =>
                                WebViewClass("http://www.denizli20haber.com"))),
                  )
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Image.network(
                      "http://hobedtech.com/wp-content/uploads/2020/03/cropped-unnamed-e1583272353489.png",
                      width: 100,
                    ),
                    onTap: () => Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) =>
                                WebViewClass("https://www.20tv.com.tr"))),
                  )
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Image.network(
                      "http://hobedtech.com/wp-content/uploads/2020/03/cropped-unnamed-e1583272353489.png",
                      width: 100,
                    ),
                    onTap: () => Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => WebViewClass(
                                "https://www.canliradyodinle.fm"))),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Beginning()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebViewClass extends StatefulWidget {
  String url;

  WebViewClass(this.url);

  WebViewState createState() => WebViewState(url);
}

class WebViewState extends State<WebViewClass> {
  String url;
  Future<void> _launched;

  WebViewState(this.url);

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  num position = 1;

  final key = UniqueKey();

  doneLoading(String A) {
    setState(() {
      position = 0;
    });
  }

  startLoading(String A) {
    setState(() {
      position = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  openWhatsapp() async {
    var phone = "";
    var whatsappUrl = "https://wa.me/+/";
    await canLaunch(whatsappUrl)
        ? launch(whatsappUrl)
        : print(
        "open whatsapp app link or do a snackbar with notification that there is no whatsapp installed");
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    print(url + "  " + "bu url ");
    return Scaffold(
      appBar: AppBar(
        leading: NavigationControlsBack(_controller.future),
        actions: <Widget>[
          NavigationControlsNext(_controller.future),
        ],
      ),
      body: IndexedStack(index: position, children: <Widget>[
        WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          // TODO(iskakaushik): Remove this when collection literals makes it to stable.
          // ignore: prefer_collection_literals
          javascriptChannels: <JavascriptChannel>[
            _toasterJavascriptChannel(context),
          ].toSet(),

          onPageStarted: startLoading,
          onPageFinished: doneLoading,
          gestureNavigationEnabled: true,
        ),
        Container(
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()),
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: InkWell(
                onTap: openWhatsapp,
                child: Image.network(
                  "https://cdn2.iconfinder.com/data/icons/social-messaging-ui-color-shapes-2-free/128/social-whatsapp-circle-512.png",
                  width: 30,
                ),
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: InkWell(child: Icon(CupertinoIcons.phone),onTap: () async {
                String number;
                number = "01111111";
                String telephoneUrl = "tel:$number";

                // kıbrıs 35.095192, 33.203430

                if (await canLaunch(telephoneUrl)) {
                  await launch(telephoneUrl);
                } else {
                  throw "Can't phone that number.";
                }
              },), label: "")
        ],
      ),
    );
  }


  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}

class NavigationControlsBack extends StatelessWidget {
  const NavigationControlsBack(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoBack()) {
                  await controller.goBack();
                } else {
                  print("can not go back");
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class NavigationControlsNext extends StatelessWidget {
  const NavigationControlsNext(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoForward()) {
                  await controller.goForward();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
