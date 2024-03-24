import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class AzureTTS {
  Future<String?> fetchTTSData(String text) async {
    print('AzureのTTSデータを取得中...');
    String? subscriptionKey = dotenv.env['AzureKEY'];
    if (subscriptionKey == null) {
      print('環境変数「AzureKEY」が設定されていません。');
      return null;
    }
    const String region = "eastus";
    final uri = Uri.parse('https://eastus.tts.speech.microsoft.com/cognitiveservices/v1');
    final headers = {
      'Content-Type': 'application/ssml+xml',
      'X-Microsoft-OutputFormat': 'audio-16khz-32kbitrate-mono-mp3',
      'Ocp-Apim-Subscription-Key': subscriptionKey,
    };
    final body = '''
      <speak version='1.0' xml:lang='en-US'>
          <voice xml:lang='en-US' xml:gender='Female' name='en-US-JennyNeural'>$text</voice>
      </speak>
    ''';

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Azure TTSからの音声データを正常に取得しました。");
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/ttsAudio.mp3';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        print("Azure TTSから音声データを取得中にエラーが発生しました: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Azure TTSの呼び出し中にエラーが発生しました: $e");
      return null;
    }
  }
}
