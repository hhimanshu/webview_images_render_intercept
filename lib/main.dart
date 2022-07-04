// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MaterialApp(home: WebViewExample()));

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

const String kLocalExamplePage = '''
<h2>Applying for Citizenship</h2>
<p><strong>When you apply for citizenship, officials will check your status, verify that you are not prohibited from applying, and ensure that you meet the requirements.</strong></p>
<p>Your application may take several months. Please ensure that the&nbsp;<a href="https://www.canada.ca/en/immigration-refugees-citizenship/corporate/publications-manuals/discover-canada/read-online/more-information.html">Call Centre</a>&nbsp;always has your correct address while your application is being processed.</p>
<p><img src="https://www.canada.ca/content/dam/ircc/migration/ircc/english/resources/publications/discover/images/section-03a.jpg?width=590&amp;height=201" alt="Section 03a 1" /></p>
<div class="mwsbodytext text parbase section">
<h3>How to Use this Booklet to Prepare for the Citizenship Test</h3>
</div>
<div class="mwsbodytext text parbase section">
<p>This booklet will help you prepare for the citizenship test. You should:</p>
<ul>
<li>Study this guide;</li>
<li>Ask a friend or family member to help you practise answering questions about Canada;</li>
<li>Call a local school or school board, a college, a community centre or a local organization that provides services to immigrants and ask for information on citizenship classes;</li>
<li>Take English or French language classes, which the Government of Canada offers free of charge.</li>
</ul>
</div>
<div class="mwsbodytext text parbase section">
<div class="mwsbodytext text parbase section">
<h3>About the Citizenship Test</h3>
</div>
<div class="mwsbodytext text parbase section">
<p>The citizenship test is usually a written test, but it could be an interview. You will be tested on two basic requirements for citizenship: 1)&nbsp;knowledge of Canada and of the rights and responsibilities of citizenship, and 2)&nbsp;adequate knowledge of English or French. Adult applicants 55&nbsp;years of age and over do not need to write the citizenship test. The&nbsp;<em><a href="https://www.canada.ca/en/immigration-refugees-citizenship/corporate/publications-manuals/discover-canada/read-online/authorities.html">Citizenship Regulations</a></em>&nbsp;provide information on how your ability to meet the knowledge of Canada requirement is determined.</p>
</div>
<div class="mwsbodytext text parbase section">
<p><img class="pull-right mrgn-lft-md" src="https://www.canada.ca/content/dam/ircc/migration/ircc/english/resources/publications/discover/images/section-03c.jpg" alt="" />All the citizenship test questions are based on the subject areas noted in the&nbsp;<em>Citizenship Regulations</em>, and all required information is provided in this study guide.</p>
</div>
<div class="mwsbodytext text parbase section"><img src="http://0.0.0.0:8055/assets/87aabcc6-73b3-442a-9d9b-96a446e7bf32?access_token=uPS_itkVoUmqNe_MjySGZSt6xaGDE5-9&amp;width=138&amp;height=158" alt="Image-2" /></div>
<div class="mwsbodytext text parbase section">
<div class="mwsbodytext text parbase section">
<h3>After the Test</h3>
</div>
<div class="mwsbodytext text parbase section">
<p>If you pass the test and meet all the other requirements, you will receive a Notice to Appear to&nbsp;<em>Take the Oath of Citizenship</em>. This document tells you the date, time and place of your citizenship ceremony.</p>
<p>At the ceremony, you will:</p>
<ul>
<li>Take the Oath of Citizenship;</li>
<li>Sign the oath form; and</li>
<li>Receive your Canadian Citizenship Certificate.</li>
</ul>
<p>If you do not pass the test, you will receive a notification indicating the next steps.</p>
<p><strong>You are encouraged to bring your family and friends to celebrate this occasion.</strong></p>
<p><img src="http://0.0.0.0:8055/assets/2f8afa9c-903a-4727-b1f0-bb27e65455ec?access_token=uPS_itkVoUmqNe_MjySGZSt6xaGDE5-9&amp;width=590&amp;height=158" alt="Image-3" /></p>
</div>
</div>
</div>
''';
const String kLocalExamplePage1 = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>

<h1>Local demo page</h1>
<p>
  This is an example page used to demonstrate how to load a local file or HTML
  string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
  webview</a> plugin.
</p>

</body>
</html>
''';

const String kTransparentBackgroundPage = '''
  <!DOCTYPE html>
  <html>
  <head>
    <title>Transparent background test</title>
  </head>
  <style type="text/css">
    body { background: transparent; margin: 0; padding: 0; }
    #container { position: relative; margin: 0; padding: 0; width: 100vw; height: 100vh; }
    #shape { background: red; width: 200px; height: 200px; margin: 0; padding: 0; position: absolute; top: calc(50% - 100px); left: calc(50% - 100px); }
    p { text-align: center; }
  </style>
  <body>
    <div id="container">
      <p>Transparent background test</p>
      <div id="shape"></div>
    </div>
  </body>
  </html>
''';

class WebViewExample extends StatefulWidget {
  const WebViewExample({Key? key, this.cookieManager}) : super(key: key);

  final CookieManager? cookieManager;

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          NavigationControls(_controller.future),
          SampleMenu(_controller.future, widget.cookieManager),
        ],
      ),
      body: WebView(
        initialUrl:
            'https://www.canada.ca/en/immigration-refugees-citizenship/corporate/publications-manuals/discover-canada/read-online/applying-citizenship.html',
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
          const removePagination =
              'document.getElementsByClassName("pagination")[0].hidden = true';
          final controller = await _controller.future;
          cleanupLoadedHtmlPage(controller);
        },
        gestureNavigationEnabled: true,
        backgroundColor: const Color(0x00000000),
      ),
      // floatingActionButton: favoriteButton(),
    );
  }

  void cleanupLoadedHtmlPage(WebViewController controller) {
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
    for (var jsString in javascriptToExecute) {
      // print("removing $jsString");
      controller.runJavascript(jsString);
    }
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

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          return FloatingActionButton(
            onPressed: () async {
              String? url;
              if (controller.hasData) {
                url = await controller.data!.currentUrl();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    controller.hasData
                        ? 'Favorited $url'
                        : 'Unable to favorite',
                  ),
                ),
              );
            },
            child: const Icon(Icons.favorite),
          );
        });
  }
}

enum MenuOptions {
  navigationDelegate,
  loadLocalFile,
  loadFlutterAsset,
  loadHtmlString,
  transparentBackground,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller, CookieManager? cookieManager, {Key? key})
      : cookieManager = cookieManager ?? CookieManager(),
        super(key: key);

  final Future<WebViewController> controller;
  late final CookieManager cookieManager;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          key: const ValueKey<String>('ShowPopupMenu'),
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.navigationDelegate:
                _onNavigationDelegateExample(controller.data!, context);
                break;
              case MenuOptions.loadLocalFile:
                _onLoadLocalFileExample(controller.data!, context);
                break;
              case MenuOptions.loadFlutterAsset:
                _onLoadFlutterAssetExample(controller.data!, context);
                break;
              case MenuOptions.loadHtmlString:
                _onLoadHtmlStringExample(controller.data!, context);
                break;
              case MenuOptions.transparentBackground:
                _onTransparentBackground(controller.data!, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.navigationDelegate,
              child: Text('Navigation Delegate example'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.loadHtmlString,
              child: Text('Load HTML string'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.loadLocalFile,
              child: Text('Load local file'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.loadFlutterAsset,
              child: Text('Load Flutter Asset'),
            ),
            const PopupMenuItem<MenuOptions>(
              key: ValueKey<String>('ShowTransparentBackgroundExample'),
              value: MenuOptions.transparentBackground,
              child: Text('Transparent background example'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
  }

  Future<void> _onLoadLocalFileExample(
      WebViewController controller, BuildContext context) async {
    final String pathToIndex = await _prepareLocalFile();

    await controller.loadFile(pathToIndex);
  }

  Future<void> _onLoadFlutterAssetExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  Future<void> _onLoadHtmlStringExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(kLocalExamplePage);
  }

  Future<void> _onTransparentBackground(
      WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(kTransparentBackgroundPage);
  }

  static Future<String> _prepareLocalFile() async {
    final String tmpDir = (await getTemporaryDirectory()).path;
    final File indexFile = File(
        <String>{tmpDir, 'www', 'index.html'}.join(Platform.pathSeparator));

    await indexFile.create(recursive: true);
    await indexFile.writeAsString(kLocalExamplePage);

    return indexFile.path;
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
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoBack()) {
                        await controller.goBack();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No back history item')),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoForward()) {
                        await controller.goForward();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No forward history item')),
                        );
                        return;
                      }
                    },
            ),
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
