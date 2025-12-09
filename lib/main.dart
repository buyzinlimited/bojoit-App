import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BojoApp()); // FIXED (removed const)
}

class BojoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bojoit App",
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController webViewController;
  final WebUri url = WebUri("https://bojoit.com"); // FIXED Uri → WebUri

  double progress = 0;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    checkInternet();
    Connectivity().onConnectivityChanged.listen((_) => checkInternet());
  }

  Future<void> checkInternet() async {
    var result = await Connectivity().checkConnectivity();
    setState(() => isOffline = result == ConnectivityResult.none);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: isOffline
              ? _noInternetUI()
              : Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(url: url),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          javaScriptEnabled: true,
                          mediaPlaybackRequiresUserGesture: false,
                        ),
                      ),
                      onWebViewCreated: (controller) =>
                          webViewController = controller,
                      onProgressChanged: (_, pct) =>
                          setState(() => progress = pct / 100),
                    ),
                    if (progress < 1) LinearProgressIndicator(value: progress),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _noInternetUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 80),
          const SizedBox(height: 10),
          Text("No Internet Connection"),
          ElevatedButton(onPressed: checkInternet, child: Text("Retry"))
        ],
      ),
    );
  }
}
