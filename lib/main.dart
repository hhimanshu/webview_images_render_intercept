// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MaterialApp(home: WebViewExample()));

class WebViewExample extends StatefulWidget {
  const WebViewExample({Key? key}) : super(key: key);

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  bool pageLoaded = false;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  static Route<Object?> _dialogBuilder(
      BuildContext context, Object? arguments) {
    return DialogRoute<void>(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (BuildContext context) =>
          const AlertDialog(title: Text('Material Alert!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!pageLoaded) {
      //Navigator.of(context).restorablePush(_dialogBuilder);
    }
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        centerTitle: true,
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          NavigationControls(_controller.future),
        ],
      ),

      body: Stack(
        children: [
          WebView(
            initialUrl:
                'https://www.canada.ca/en/immigration-refugees-citizenship/corporate/publications-manuals/discover-canada/read-online/canadas-history.html',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            onProgress: (int progress) {
              print('WebView is loading (progress : $progress%)');
            },
            javascriptChannels: <JavascriptChannel>{
              _toasterJavascriptChannel(context),
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                print('blocking navigation to $request}');
                return NavigationDecision.prevent;
              }
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print('Page started loading: $url');
            },
            onPageFinished: (String url) async {
              print('Page finished loading: $url');
              final controller = await _controller.future;
              var cleanupFuture = cleanupLoadedHtmlPage(controller);
              Future.wait(cleanupFuture).then((value) {
                print("Clean up done => $value");
                setState(() {
                  pageLoaded = true;
                });
              });
            },
          ),
          Visibility(
              visible: !pageLoaded,
              child: const Center(
                child: Opacity(
                  opacity: 1.0,
                  child: CircularProgressIndicator(),
                ),
              ))
        ],
      ),
      // floatingActionButton: favoriteButton(),
    );
  }

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

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture, {Key? key})
      : assert(_webViewControllerFuture != null),
        super(key: key);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController? controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller!.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
