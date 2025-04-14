// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

void registerWebAdView() {
  const adId = 'puan-ekrani-reklami';
  final adElement = html.DivElement()
    ..id = adId
    ..innerHtml = '''
      <ins class="adsbygoogle"
           style="display:block; text-align:center;"
           data-ad-client="ca-pub-XXXXXXXXXXXXXXXX"
           data-ad-slot="1234567890"
           data-ad-format="auto"
           data-full-width-responsive="true"></ins>
      <script>
          (adsbygoogle = window.adsbygoogle || []).push({});
      </script>
    ''';

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(adId, (int viewId) => adElement);
}
