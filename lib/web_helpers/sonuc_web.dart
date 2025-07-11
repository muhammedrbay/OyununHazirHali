// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

void registerWebAdView() {
  const adId = 'puan-ekrani-reklami';
  final adElement = html.DivElement()
    ..id = adId
    ..innerHtml = '''
      <ins class="adsbygoogle"
           style="display:block; text-align:center;"
           data-ad-client="ca-app-pub-9576499265117171"
           data-ad-slot="9780052017"
           data-ad-format="auto"
           data-full-width-responsive="true"></ins>
      <script>
          (adsbygoogle = window.adsbygoogle || []).push({});
      </script>
    ''';

  ui_web.platformViewRegistry
      .registerViewFactory(adId, (int viewId) => adElement);
}
