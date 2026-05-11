import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslatorService {
  static Future<String> translate(String text) async {
    if (text.trim().isEmpty) return '';

    final encoded = Uri.encodeComponent(text);
    final url = Uri.parse(
      'https://api.mymemory.translated.net/get?q=$encoded&langpair=en|id',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['responseData']['translatedText'] ??
            'Terjemahan tidak ditemukan';
      } else {
        return 'Error: Gagal menghubungi server (${response.statusCode})';
      }
    } catch (e) {
      return 'Error: Tidak ada koneksi internet';
    }
  }
}