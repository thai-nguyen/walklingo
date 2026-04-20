import "package:http/http.dart" as http;
import "package:xml/xml.dart";

import "../domain/librivox_chapter.dart";

/// Parse RSS LibriVox (chuẩn RSS 2.0 + enclosure MP3) — không dùng webfeed (tránh xung đột intl).
class RssChapterParser {
  RssChapterParser(this._http);

  final http.Client _http;

  Future<List<LibrivoxChapter>> fetchChapters(String rssUrl) async {
    if (rssUrl.isEmpty) return [];

    final uri = Uri.tryParse(rssUrl);
    if (uri == null || !uri.hasScheme) {
      // ignore: avoid_print
      print("[RssChapterParser] invalid rss url: $rssUrl");
      return [];
    }

    // ignore: avoid_print
    print("[RssChapterParser] GET $uri");
    final response =
        await _http.get(uri).timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw RssFetchException(
        "RSS ${response.statusCode} for $rssUrl",
        statusCode: response.statusCode,
      );
    }

    try {
      return _parseRssXml(response.body);
    } catch (e, st) {
      // ignore: avoid_print
      print("[RssChapterParser] parse error: $e\n$st");
      throw RssParseException("Invalid RSS XML: $e");
    }
  }

  List<LibrivoxChapter> _parseRssXml(String body) {
    final doc = XmlDocument.parse(body);
    final items = doc.findAllElements("item");
    final chapters = <LibrivoxChapter>[];
    var i = 0;

    for (final item in items) {
      i++;
      final titleEl = item.getElement("title");
      final title = titleEl?.innerText.trim();
      final displayTitle =
          title != null && title.isNotEmpty ? title : "Chapter $i";

      final audioUrl = _extractEnclosureUrl(item);
      if (audioUrl.isEmpty) {
        // ignore: avoid_print
        print("[RssChapterParser] skip item without enclosure: $displayTitle");
        continue;
      }

      chapters.add(LibrivoxChapter(title: displayTitle, audioUrl: audioUrl));
    }

    // ignore: avoid_print
    print("[RssChapterParser] extracted ${chapters.length} chapters");
    return chapters;
  }

  /// RSS 2.0: &lt;enclosure url="..." type="audio/mpeg" /&gt;
  static String _extractEnclosureUrl(XmlElement item) {
    for (final enc in item.findElements("enclosure")) {
      final url = enc.getAttribute("url")?.trim();
      if (url != null && url.isNotEmpty) return url;
    }

    final link = item.getElement("link")?.innerText.trim();
    if (link != null &&
        link.isNotEmpty &&
        (link.toLowerCase().contains(".mp3"))) {
      return link;
    }

    return "";
  }
}

class RssFetchException implements Exception {
  RssFetchException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class RssParseException implements Exception {
  RssParseException(this.message);

  final String message;

  @override
  String toString() => message;
}
