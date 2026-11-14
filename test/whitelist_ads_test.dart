import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/screens/whitelist_screen.dart';
import 'package:instalander/services/ads_service.dart';
import 'package:instalander/widgets/native_ad_card.dart';
import 'package:provider/provider.dart';

class _WhitelistProvider extends AppProvider {
  @override
  Set<String> get whitelist => {for (var i = 0; i < 40; i++) 'profile_$i'};
}

void main() {
  testWidgets(
    'whitelist inserts ads in list and grid and honors disabled ads',
    (tester) async {
      tester.view.reset();
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final ads = AdsService.instance;
      ads.adsEnabled.value = true;
      ads.canRequestAds.value = false;
      addTearDown(() => ads.adsEnabled.value = false);
      final app = _WhitelistProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: app,
          child: const MaterialApp(home: WhitelistScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NativeAdCard), findsWidgets);
      await tester.tap(find.text('Griglia'));
      await tester.pumpAndSettle();
      expect(find.byType(NativeAdCard), findsWidgets);
      ads.adsEnabled.value = false;
      await tester.pumpAndSettle();
      expect(find.byType(NativeAdCard), findsNothing);
      expect(find.text('@profile_0'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      app.dispose();
    },
  );
}
