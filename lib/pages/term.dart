import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Term extends StatefulWidget {
  const Term({super.key});

  @override
  State<Term> createState() => _TermState();
}

class _TermState extends State<Term> {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );

  Map arguments = {};

  @override
  void initState() {
    super.initState();

    arguments = Get.arguments;

    _loadLocalHTML();
  }

  Future<void> _loadLocalHTML() async {
    try {
      // 从 assets 中加载 HTML 文件内容
      final String htmlContent = await rootBundle.loadString(arguments['htmlFilePath']);

      // 使用 loadHtmlString 方法加载 HTML 内容
      controller.loadHtmlString(htmlContent);
    } catch (e) {
      // 处理加载错误
      debugPrint('Error loading local HTML file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments['title']),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
