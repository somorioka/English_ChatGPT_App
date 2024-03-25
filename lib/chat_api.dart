import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  final String? apiKey = dotenv.env['ChatGPTKEY'];
  Future<String> fetchResponse(
      String theme, String difficulty) async {
    final prompt = "あなたはプロのライターです。以下の【テーマ】について記事を生成してください。【条件】【目的】【形式】の内容を踏まえて、英語で{英語本文}を作成してください。その後日本語で{日本語訳}を作成してください。\n#テーマ\n${theme}\n#条件\n- ${difficulty}\n- 読者の知的レベル:高校生\n- 語数:100語程度\n#目的\n- 英語を学習するため\n- 教養を身につけるため\n#形式\n- 英文の始まりにはタイトルをつけず、いきなり本文から始めること\n- 英文と日本語訳の間には必ず空行を入れること";
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
