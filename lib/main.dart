import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MaterialApp(home: PageLoadApp()));
final isLoading = ValueNotifier<bool>(true);

class PageLoadApp extends StatefulWidget {
  const PageLoadApp({Key? key}) : super(key: key);

  @override
  State<PageLoadApp> createState() => _PageLoadAppState();
}

class _PageLoadAppState extends State<PageLoadApp> {
  static String get _url {
    // await Future.delayed(const Duration(seconds: 10));
    return 'https://www.canada.ca/en/immigration-refugees-citizenship/corporate/publications-manuals/discover-canada/read-online/canadas-history.html';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Scaffold(
        body: ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, value, _) {
              return Scaffold(
                body: Stack(
                  children: <Widget>[
                    WebViewWidget(
                      url: _url,
                    ),
                    (value == true
                        ? Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container()),
                  ],
                ),
              );
              ;
            }),
      ));
}

class WebViewWidget extends StatefulWidget {
  final String url;

  const WebViewWidget({
    required this.url,
  });

  @override
  _WebViewWidget createState() => _WebViewWidget();
}

class _WebViewWidget extends State<WebViewWidget> {
  late WebView _webView;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  Iterable<Future<void>> cleanupLoadedHtmlPage(WebViewController controller) {
    const List<String> javascriptToExecute = [
      'document.getElementById("wb-lng").hidden = true;',
      'document.getElementById("wb-srch").hidden = true',
      'document.getElementsByClassName("gcweb-menu")[0].hidden = true',
      'document.getElementsByClassName("mwsalerts")[0].hidden = true',
      'document.getElementById("wb-bc").hidden = true',
      'document.getElementsByClassName("pagination")[0].hidden = true',
      'document.getElementsByClassName("pagedetails")[0].hidden = true',
      'document.getElementsByClassName("global-footer")[0].hidden = true'
    ];
    return javascriptToExecute.map((js) {
      print("removing $js");
      return controller.runJavascript(js);
    });
  }

  @override
  void initState() {
    super.initState();
    _webView = WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },
      onProgress: (int progress) {},
      onPageStarted: (String url) {
        isLoading.value = true;
        print('Page started loading: $url');
      },
      onPageFinished: (String url) async {
        // Navigator.pop(context);

        print('Page finished loading: $url');

        final controller = await _controller.future;
        var cleanupFuture = cleanupLoadedHtmlPage(controller);
        Future.wait(cleanupFuture).then((value) {
          print("Clean up done => $value");
          isLoading.value = false;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    //_webView = null;
  }

  @override
  Widget build(BuildContext context) => _webView;
}
