import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  final String? apiKey = dotenv.env['ChatGPTKEY'];
  Future<String> fetchResponse(
      String theme, String difficulty, double wordCount) async {
    final prompt = "あなたはプロのライターです。以下の【テーマ】について記事を生成してください。"
        "【難易度】【語数】の内容を踏まえて、英語で{英語本文}を作成してください。\n#テーマ\n${theme}\n#難易度\n${difficulty}\n#語数\n${wordCount.toInt()}";
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo', // 確認: 使用するモデル名
        'messages': [
          {'role': 'user', 'content': prompt},
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print(response.statusCode);
      throw Exception('Failed to load response');
    }
  }
}
