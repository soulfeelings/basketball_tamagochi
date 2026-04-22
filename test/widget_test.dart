import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:hooprise/providers/game_provider.dart';
import 'package:hooprise/screens/create_player_screen.dart';
import 'package:hooprise/screens/home_screen.dart';
import 'package:hooprise/screens/training_screen.dart';
import 'package:hooprise/screens/match_screen.dart';

// Fake WebView platform for testing
class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return FakePlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return FakePlatformWebViewWidget(params);
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return FakePlatformCookieManager(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return FakePlatformNavigationDelegate(params);
  }
}

class FakePlatformWebViewController extends PlatformWebViewController {
  FakePlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {}

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {}

  @override
  Future<String?> currentUrl() async => '';

  @override
  Future<bool> canGoBack() async => false;

  @override
  Future<bool> canGoForward() async => false;

  @override
  Future<void> goBack() async {}

  @override
  Future<void> goForward() async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> clearLocalStorage() async {}

  @override
  Future<String?> getTitle() async => '';

  @override
  Future<void> scrollTo(int x, int y) async {}

  @override
  Future<void> scrollBy(int x, int y) async {}

  @override
  Future<Offset> getScrollPosition() async => Offset.zero;

  @override
  Future<void> enableZoom(bool enabled) async {}

  @override
  Future<void> setUserAgent(String? userAgent) async {}

  @override
  Future<Object> runJavaScript(String javaScript) async => '';

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async => '';
}

class FakePlatformWebViewWidget extends PlatformWebViewWidget {
  FakePlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class FakePlatformCookieManager extends PlatformWebViewCookieManager {
  FakePlatformCookieManager(super.params) : super.implementation();

  @override
  Future<bool> clearCookies() async => true;

  @override
  Future<void> setCookie(WebViewCookie cookie) async {}
}

class FakePlatformNavigationDelegate extends PlatformNavigationDelegate {
  FakePlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnNavigationRequest(NavigationRequestCallback onNavigationRequest) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback onWebResourceError) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}

  @override
  Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback onHttpAuthRequest) async {}

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}
}

void main() {
  setUpAll(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  testWidgets('Full game flow test', (WidgetTester tester) async {
    final game = GameProvider();

    Widget wrapScreen(Widget screen) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: ChangeNotifierProvider.value(
          value: game,
          child: screen,
        ),
      );
    }

    // Screen 1: Create Player
    await tester.pumpWidget(wrapScreen(const CreatePlayerScreen()));
    await tester.pumpAndSettle();
    expect(find.text('CREATE YOUR\nPLAYER'), findsOneWidget);
    expect(find.text('START CAREER'), findsOneWidget);

    // Enter name and create player
    await tester.enterText(find.byType(TextField), 'LeBron Jr');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shooting Guard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('START CAREER'));
    await tester.pumpAndSettle();

    expect(game.hasPlayer, isTrue);
    expect(game.player!.name, 'LeBron Jr');
    expect(game.player!.position, 'Shooting Guard');

    // Screen 2: Home Screen (use pump() instead of pumpAndSettle() due to periodic timer)
    await tester.pumpWidget(wrapScreen(const HomeScreen()));
    await tester.pump();
    expect(find.text('LeBron Jr'), findsOneWidget);
    expect(find.text('TRAIN'), findsOneWidget);
    expect(find.text('MATCH'), findsOneWidget);
    expect(find.text('EAT'), findsOneWidget);

    // Screen 3: Training
    await tester.pumpWidget(wrapScreen(const TrainingScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Training'), findsOneWidget);
    expect(find.text('Shooting'), findsOneWidget);

    final oldShooting = game.player!.shooting;
    await tester.tap(find.text('Shooting'));
    await tester.pumpAndSettle();
    expect(game.player!.shooting, greaterThan(oldShooting));

    // Screen 4: Match
    await tester.pumpWidget(wrapScreen(const MatchScreen()));
    await tester.pumpAndSettle();
    expect(find.text('START MATCH'), findsOneWidget);

    await tester.tap(find.text('START MATCH'));
    await tester.pumpAndSettle();
    expect(game.player!.matchesPlayed, 1);
    expect(find.text('BACK TO HOME'), findsOneWidget);
  });
}
