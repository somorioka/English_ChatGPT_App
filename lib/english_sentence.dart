import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'azure_api.dart';
import 'chat_api.dart';

class ResultPage extends StatefulWidget {
  final String theme;
  final String difficulty;
  // final String phrase;

  const ResultPage({
    Key? key,
    required this.theme,
    required this.difficulty,
    // required this.phrase,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String _generatedText = '';
  String _translatedText = ''; // 翻訳されたテキストを保持
  bool _showTranslatedText = false; // 翻訳テキストの表示制御
  bool _isTextLoading = true;
  bool _isAudioLoading = true;
  bool _isTranslateLoading = true;
  String? _ttsFilePath;
  late AudioPlayer _audioPlayer;
  double _volume = 1.0;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _audioPlayer = AudioPlayer();
  }

  void _initializeScreen() async {
    // _fetchAndSetResponseTextを実行して、応答テキストを取得
    await _fetchAndSetResponseText();
    // 応答テキストが取得できたら、そのテキストを用いて日本語訳とTTSデータを取得
    if (_generatedText.isNotEmpty) {
      _translateText(_generatedText);
      // 英語のテキストをAzure TTSで読み上げる
      final ttsFilePath = await AzureTTS().fetchTTSData(_generatedText);
      if (ttsFilePath != null) {
        setState(() {
          _ttsFilePath = ttsFilePath;
        });
        await _initializeAudioPlayer(); // ここで_audioPlayerを初期化
      }
    }
  }

  Future<void> _fetchAndSetResponseText() async {
    try {
      final prompt =
          ChatService().generateEnglishPrompt(widget.theme, widget.difficulty);
      final responseText = await ChatService().fetchResponse(prompt);
      setState(() {
        _generatedText = responseText;
        _isTextLoading = false;
      });
    } catch (e) {
      setState(() {
        _generatedText = 'エラーが発生しました: $e';
        _isTextLoading = false;
      });
    }
  }

  Future<void> _translateText(String textToTranslate) async {
    try {
      // ここでtextToTranslateを変数に、promptを返すメソッドを書く。
      //そのpromptをfetchResponseにぶちこんでChatGPTに返答してもらう
      final prompt = ChatService().generateJapanesePrompt(textToTranslate);
      final responseText = await ChatService().fetchResponse(prompt);
      setState(() {
        _translatedText = responseText;
        _isTranslateLoading = false;
      });
    } catch (e) {
      setState(() {
        _generatedText = 'エラーが発生しました: $e';
        _isTextLoading = false;
      });
    }
  }

  Future<void> _initializeAudioPlayer() async {
    await _audioPlayer.setFilePath(_ttsFilePath!);
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      setState(() {
        _isAudioLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _copyToClipboard() {
      const separator = '\n\n';
      // 英文(_generatedText)と日本語訳(_translatedText)を結合
      final combinedText = utf8.decode(_generatedText.runes.toList()) +
          separator +
          utf8.decode(_translatedText.runes.toList());
      Clipboard.setData(ClipboardData(text: combinedText)).then((_) {
        // コピー完了後の処理（オプション）
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('テキストをクリップボードにコピーしました')),
        );
      }).catchError((error) {
        // エラー処理（オプション）
        print("クリップボードへのコピーに失敗しました: $error");
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 35.0,
        title: const Text(
          '英文を読む',
          style: TextStyle(
              fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        // アイコンテーマを設定してアイコンの色を変更
        iconTheme: IconThemeData(
          color: Colors.black87, // ここで戻るボタンの色を指定
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _copyToClipboard, icon: Icon(Icons.content_copy))
        ],
      ),
      body: _isTextLoading
          ? Center(
              child: Column(
              children: [
                Image.asset('assets/images/nowloading.gif'),
                const Text('英文と日本語訳を生成しています…')
              ],
            ))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                        child: Container(
                      padding: EdgeInsets.all(16.0), // パディングを設定
                      margin: EdgeInsets.all(8.0), // マージンを設定
                      decoration: BoxDecoration(
                        color: Colors.white, // 背景色
                        borderRadius: BorderRadius.circular(10), // 角の丸み
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // 影の色
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 3), // 影の位置調整
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            utf8.decode(_generatedText.runes.toList()),
                            style: const TextStyle(
                              fontSize: 16, // フォントサイズ
                              fontWeight: FontWeight.bold, // フォントウェイト
                              color: Colors.black87, // 文字色
                              height: 1.5, // 行間
                            ),
                          ),
                          // buildメソッド内のUIコードにボタンを追加
                          const SizedBox(
                            height: 30,
                          ),
                          _showTranslatedText
                              ? Text(
                                  utf8.decode(_translatedText.runes.toList()),
                                  style: const TextStyle(
                                    fontSize: 16, // フォントサイズ
                                    fontWeight: FontWeight.bold, // フォントウェイト
                                    color: Colors.black54, // 文字色
                                    height: 1.5, // 行間
                                  ),
                                )
                              : TextButton(
                                  onPressed: _isTranslateLoading ? null : () {
                                    // ボタンが押されたときのアクション
                                    setState(() {
                                      _showTranslatedText = true;
                                    });
                                  },
                                  child: const Text('日本語訳を見る'),
                                ),
                        ],
                      ),
                    )),
                  ),
                  // プログレスバー
                  StreamBuilder<Duration>(
                    stream: _audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = _audioPlayer.duration ?? Duration.zero;
                      return Slider(
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble(),
                        value: position.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          _audioPlayer
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                      );
                    },
                  ),
                  _isAudioLoading
                      ? const Text('音声取得中...')
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // リスタートボタン
                            IconButton(
                              icon: const Icon(Icons.restart_alt), // リスタートアイコンに変更
                              onPressed: () {
                                // 最初の位置（0秒）にシークして再生を開始する
                                _audioPlayer.seek(Duration.zero);
                                _audioPlayer.play(); // オプショナル: 自動的に再生を開始したい場合
                              },
                            ),
                            // 再生 & 停止トグルボタン
                            IconButton(
                              icon: Icon(_audioPlayer.playing
                                  ? Icons.pause
                                  : Icons.play_arrow),
                              onPressed: () {
                                if (_audioPlayer.playing) {
                                  _audioPlayer.pause();
                                } else {
                                  _audioPlayer.play();
                                }
                              },
                            ),
                            // 速度変更ボタン
                            PopupMenuButton<double>(
                              initialValue: _speed,
                              icon: Icon(Icons.speed),
                              onSelected: (speed) {
                                setState(() {
                                  _speed = speed;
                                  _audioPlayer.setSpeed(speed);
                                });
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 0.5,
                                  child: Text("0.5x"),
                                ),
                                PopupMenuItem(
                                  value: 0.75,
                                  child: Text("0.75x"),
                                ),
                                PopupMenuItem(
                                  value: 1.0,
                                  child: Text("1.0x"),
                                ),
                                PopupMenuItem(
                                  value: 1.25,
                                  child: Text("1.25x"),
                                ),
                                PopupMenuItem(
                                  value: 1.5,
                                  child: Text("1.5x"),
                                ),
                              ],
                            ),
                          ],
                        )
                ],
              ),
            ),
    );
  }
}
