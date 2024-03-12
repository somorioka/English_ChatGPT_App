
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

import 'chat_service.dart';
import 'package:http/http.dart' as http;

class EnglishGeneratorScreen extends StatefulWidget {
  @override
  _EnglishGeneratorScreenState createState() => _EnglishGeneratorScreenState();
}

class _EnglishGeneratorScreenState extends State<EnglishGeneratorScreen> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  bool _isLoading = false; // ローディング状態の管理
  final _themeController = TextEditingController();
  String _difficulty = '小学生';
  double _wordCount = 50;
  String _generatedText = ''; // 追加: APIからのレスポンスを格納

  void _generatePrompt() async {
    final theme = _themeController.text;
    final difficulty = _difficulty;
    final wordCount = _wordCount;

    setState(() {
      _isLoading = true; // ローディング開始
    });

    try {
      final responseText =
          await ChatService().fetchResponse(theme, difficulty, wordCount);
      setState(() {
        _generatedText = responseText; // 状態更新: APIからのレスポンスで
        _isLoading = false; // ローディング終了
      });
    } catch (e) {
      setState(() {
        _generatedText = 'エラーが発生しました: $e'; // エラー時の処理
        _isLoading = false; // ローディング終了
      });
    }
  }

  Future<String?> fetchTTSData(String text) async {
    print('fetchTTSDataメソッドが実行されました');
    String? subscriptionKey = dotenv.env['AzureKEY']!;
    const String region = "eastus";
    final uri = Uri.parse(
        'https://eastus.tts.speech.microsoft.com/cognitiveservices/v1');
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
        print("通信が正常に行われました");
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/ttsAudio.mp3';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        print("Error fetching TTS: ${response.reasonPhrase}");
        print(response.statusCode);
      }
    } catch (e) {
      print("Error calling Azure TTS: $e");
    }
    return null;
  }

  Future<void> playTTS(String filePath) async {
    print('playTTSメソッドが実行されました');
    try {
      await audioPlayer.play(DeviceFileSource(filePath));
      setState(() => isPlaying = true);
      audioPlayer.onPlayerComplete.listen((event) {
        setState(() => isPlaying = false);
      });
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> stopTTS() async {
    try {
      // 再生中の音声を停止
      await audioPlayer.stop();
      setState(() => isPlaying = false); // 状態を更新
      print("音声の再生が停止されました");
    } catch (e) {
      print("音声の停止中にエラーが発生しました: $e");
    }
  }

  Future<void> pauseTTS() async {
    try {
      await audioPlayer.pause(); // 再生を一時停止
      setState(() => isPlaying = false); // 状態を更新
      print("音声の再生が一時停止されました");
    } catch (e) {
      print("音声の一時停止中にエラーが発生しました: $e");
    }
  }

  Future<void> resumeTTS() async {
    try {
      await audioPlayer.resume(); // 再生を再開
      setState(() => isPlaying = true); // 状態を更新
    } catch (e) {
      print("音声の再開中にエラーが発生しました: $e");
    }
  }

  Future<void> playOrFetchTTS(String text) async {
  // テキストから一意のハッシュ値を生成する
  var bytes = utf8.encode(text); // テキストをバイト配列に変換
  var digest = sha256.convert(bytes); // SHA-256 ハッシュを計算
  String fileName = 'tts_$digest.mp3'; // ファイル名

  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);

  // ファイルが既に存在するかチェック
  if (await file.exists()) {
    print("ファイルは既に存在します。ダウンロードせずに再生します。");
    await audioPlayer.play(DeviceFileSource(filePath));
  } else {
    print("ファイルが存在しません。Azureからダウンロードします。");
    // Azureから音声データを取得し、ファイルに保存する処理をここに記述
    // 以下は fetchTTSData メソッドの擬似的な呼び出しです
    final fetchedFilePath = await fetchTTSData(text);
    if (fetchedFilePath != null) {
      await audioPlayer.play(DeviceFileSource(fetchedFilePath));
    }
  }
}
  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer(); // initStateで初期化
  }

  @override
  void dispose() {
    audioPlayer.dispose(); // リソースを解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _themeController,
              decoration: InputDecoration(labelText: 'テーマ'),
            ),
            DropdownButton<String>(
              value: _difficulty,
              onChanged: (String? newValue) {
                setState(() {
                  _difficulty = newValue!;
                });
              },
              items: <String>['小学生', '中学生', '高校生']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Slider(
              value: _wordCount,
              min: 50,
              max: 200,
              divisions: 150,
              label: _wordCount.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _wordCount = value;
                });
              },
            ),

            ElevatedButton(
              onPressed: _generatePrompt,
              child: Text('生成'),
            ),
            SizedBox(height: 20), // 結果表示前のスペース

            ElevatedButton(
              onPressed: _generatedText.isNotEmpty
                  ? () async {
                      final String? filePath = await fetchTTSData(
                          utf8.decode(_generatedText.runes.toList()));
                      if (filePath != null) {
                        await playTTS(filePath);
                      }
                    }
                  : null, // _generatedTextが空でない場合のみ実行
              child: const Text('読み上げ音声を取得'),
            ),
            ElevatedButton(
              onPressed: () async {
                await playOrFetchTTS(utf8.decode(_generatedText.runes.toList()));
              }, 
              child: const Text('テキストを読み上げる'),),
            IconButton(
              onPressed: () {
                if (isPlaying) {
                  pauseTTS(); // 既に再生中の場合は停止
                } else {
                  resumeTTS(); // 停止中の場合は再開
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow, // 再生状態に応じてアイコンを切り替え
              ),
            ),

            SizedBox(height: 20), // 結果表示前のスペース
            _isLoading
                ? CircularProgressIndicator() // ローディング中はインジケータを表示
                : Text(utf8.decode(
                    _generatedText.runes.toList())), // ローディングが終了したら結果を表示
          ],
        ),
      ),
    );
  }
}
