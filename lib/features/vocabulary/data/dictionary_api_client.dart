import "dart:convert";

import "package:http/http.dart" as http;

import "../../../core/failures.dart";
import "word_normalize.dart";

class DictionaryEntryDto {
  const DictionaryEntryDto({
    required this.word,
    this.phonetic,
    this.phoneticsAudioUrl,
    this.definitionPreview,
    this.examplePreview,
  });

  final String word;
  final String? phonetic;
  final String? phoneticsAudioUrl;
  final String? definitionPreview;
  final String? examplePreview;
}

class DictionaryApiClient {
  DictionaryApiClient({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static const _base = "https://api.dictionaryapi.dev/api/v2/entries/en";

  Future<DictionaryEntryDto> lookup(String rawInput) async {
    final lemma = normalizeEnglishLemma(rawInput);
    if (lemma.isEmpty) {
      throw DictionaryFailure("Chỉ hỗ trợ từ tiếng Anh (chữ Latin).");
    }
    final uri = Uri.parse("$_base/${Uri.encodeComponent(lemma)}");
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode == 404) {
        throw DictionaryFailure("Không tìm thấy từ \"$lemma\" trong từ điển.");
      }
      if (res.statusCode != 200) {
        throw DictionaryFailure("API từ điển: ${res.statusCode}");
      }
      final list = jsonDecode(res.body) as List<dynamic>;
      if (list.isEmpty) {
        throw DictionaryFailure("Không có dữ liệu cho \"$lemma\".");
      }
      final first = list.first as Map<String, dynamic>;
      return _mapEntry(first, lemma);
    } on DictionaryFailure {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(DictionaryFailure("Lỗi tra từ: $e"), st);
    }
  }

  DictionaryEntryDto _mapEntry(Map<String, dynamic> json, String fallbackWord) {
    final word = json["word"] as String? ?? fallbackWord;
    final phonetic = json["phonetic"] as String?;

    String? audio;
    final phonetics = json["phonetics"] as List<dynamic>?;
    if (phonetics != null) {
      for (final p in phonetics) {
        final m = p as Map<String, dynamic>;
        final u = m["audio"] as String?;
        if (u != null && u.isNotEmpty) {
          audio = u;
          break;
        }
      }
    }

    String? def;
    String? ex;
    final meanings = json["meanings"] as List<dynamic>?;
    if (meanings != null && meanings.isNotEmpty) {
      final m0 = meanings.first as Map<String, dynamic>;
      final defs = m0["definitions"] as List<dynamic>?;
      if (defs != null && defs.isNotEmpty) {
        final d0 = defs.first as Map<String, dynamic>;
        def = d0["definition"] as String?;
        ex = d0["example"] as String?;
      }
    }

    return DictionaryEntryDto(
      word: word,
      phonetic: phonetic,
      phoneticsAudioUrl: audio,
      definitionPreview: def,
      examplePreview: ex,
    );
  }

  void dispose() => _client.close();
}
