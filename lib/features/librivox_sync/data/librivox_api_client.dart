import "dart:convert";

import "package:http/http.dart" as http;

/// Client gọi LibriVox JSON API (không phụ thuộc Firebase).
class LibrivoxApiClient {
  LibrivoxApiClient(this._http);

  final http.Client _http;

  static final _audiobooksUri = Uri.parse(
    "https://librivox.org/api/feed/audiobooks/?format=json",
  );

  /// Trả về danh sách map thô từ API, đã giới hạn [limit] phần tử.
  Future<List<Map<String, dynamic>>> fetchAudiobookMaps({required int limit}) async {
    // ignore: avoid_print
    print("[LibrivoxApi] GET $_audiobooksUri");
    final response = await _http
        .get(_audiobooksUri)
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw LibrivoxApiException(
        "LibriVox API ${response.statusCode}",
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    List<dynamic> rawList;

    if (decoded is Map<String, dynamic>) {
      final books = decoded["books"];
      rawList = books is List<dynamic> ? books : const [];
    } else if (decoded is List<dynamic>) {
      rawList = decoded;
    } else {
      rawList = const [];
    }

    final out = <Map<String, dynamic>>[];
    for (final item in rawList.take(limit)) {
      if (item is Map<String, dynamic>) {
        out.add(item);
      } else if (item is Map) {
        out.add(Map<String, dynamic>.from(item));
      }
    }
    // ignore: avoid_print
    print("[LibrivoxApi] parsed ${out.length} book maps (limit=$limit)");
    return out;
  }

  static String? extractBookId(Map<String, dynamic> map) =>
      map["id"]?.toString();

  static String extractTitle(Map<String, dynamic> map) =>
      map["title"]?.toString().trim().isNotEmpty == true
          ? map["title"].toString().trim()
          : "Untitled";

  static String extractUrlRss(Map<String, dynamic> map) =>
      map["url_rss"]?.toString().trim() ?? "";

  static String extractUrlTextSource(Map<String, dynamic> map) =>
      map["url_text_source"]?.toString().trim() ?? "";

  /// Ghép tác giả từ mảng LibriVox hoặc chuỗi đơn.
  static String extractAuthor(Map<String, dynamic> map) {
    final authors = map["authors"];
    if (authors is List && authors.isNotEmpty) {
      final names = <String>[];
      for (final a in authors) {
        if (a is Map<String, dynamic>) {
          final f = a["first_name"]?.toString().trim() ?? "";
          final l = a["last_name"]?.toString().trim() ?? "";
          final name = "$f $l".trim();
          if (name.isNotEmpty) names.add(name);
        }
      }
      if (names.isNotEmpty) return names.join(", ");
    }
    final single = map["author"]?.toString().trim();
    if (single != null && single.isNotEmpty) return single;
    return "Unknown";
  }
}

class LibrivoxApiException implements Exception {
  LibrivoxApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
