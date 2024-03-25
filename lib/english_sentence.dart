import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import 'azure_api.dart';
import 'chat_api.dart';

class ResultPage extends StatefulWidget {
  final String theme;
  final String difficulty;
  final String phrase;

  const ResultPage({
    Key? key,
    required this.theme,
    required this.difficulty,
    required this.phrase,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String _generatedText = '';
  bool _isLoading = true;
  String? _ttsFilePath;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _volume = 1.0;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _audioPlayer = AudioPlayer();
  }

  void _initializeScreen() async {
    // _generatePromptを実行して、応答テキストを取得
    await _generatePrompt();
    // 応答テキストが取得できたら、そのテキストを用いてTTSデータを取得
    if (_generatedText.isNotEmpty) {
      // 最初の空行（英語セクションの終了）を探す
      final endOfEnglishText = _generatedText.indexOf('\n\n');
      String englishText;
      if (endOfEnglishText != -1) {
        // 空行が見つかった場合、その直前までが英文
        englishText = _generatedText.substring(0, endOfEnglishText).trim();
      } else {
        // 空行が見つからない場合、文書の終わりまでが英文
        englishText = _generatedText.trim();
      }
      // 英語のテキストをAzure TTSで読み上げる
      final ttsFilePath = await AzureTTS().fetchTTSData(englishText);
      if (ttsFilePath != null) {
        setState(() {
          _ttsFilePath = ttsFilePath;
        });
        await _initializeAudioPlayer(); // ここで_audioPlayerを初期化
      }
    }
  }

  Future<void> _generatePrompt() async {
    try {
      final responseText = await ChatService()
          .fetchResponse(widget.theme, widget.difficulty, widget.phrase);
      setState(() {
        _generatedText = responseText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _generatedText = 'エラーが発生しました: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeAudioPlayer() async {
    await _audioPlayer.setFilePath(_ttsFilePath!);
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      setState(() {
        _isPlaying = isPlaying;
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
      Clipboard.setData(
              ClipboardData(text: utf8.decode(_generatedText.runes.toList())))
          .then((_) {
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
      body: _isLoading
          ? Center(
              child: Column(
              children: [
                Image.asset('assets/images/nowloading.gif'),
                const Text('英文とその音声を生成しています…')
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
                      child: Text(
                        utf8.decode(_generatedText.runes.toList()),
                        style: TextStyle(
                          fontSize: 16, // フォントサイズ
                          fontWeight: FontWeight.bold, // フォントウェイト
                          color: Colors.black, // 文字色
                          height: 1.5, // 行間
                        ),
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
                  // コントロールボタン
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     IconButton(
                  //       icon: Icon(Icons.play_arrow),
                  //       onPressed:
                  //           _isPlaying ? null : () => _audioPlayer.play(),
                  //     ),
                  //     IconButton(
                  //       icon: Icon(Icons.stop),
                  //       onPressed:
                  //           _isPlaying ? () => _audioPlayer.stop() : null,
                  //     ),
                  //     IconButton(
                  //       icon: Icon(Icons.pause),
                  //       onPressed:
                  //           _isPlaying ? () => _audioPlayer.pause() : null,
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 音量調整ボタン
                      IconButton(
                        icon: Icon(Icons.volume_up),
                        onPressed: () {
                          setState(() {
                            _volume = _volume == 1.0 ? 0.0 : 1.0; // 音量をトグル
                            _audioPlayer.setVolume(_volume);
                          });
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
                            value: 1.0,
                            child: Text("1.0x"),
                          ),
                          PopupMenuItem(
                            value: 1.5,
                            child: Text("1.5x"),
                          ),
                          PopupMenuItem(
                            value: 2.0,
                            child: Text("2.0x"),
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
