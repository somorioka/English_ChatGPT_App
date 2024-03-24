import 'dart:convert';

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _generatePrompt();
  }

  void _generatePrompt() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 35.0,
        title: const Text(
          '英文を読む',
          style: TextStyle(
              fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            color: Colors.black87,
            icon: Icon(Icons.edit_note),
            onPressed: () {
              // アイコンボタンの処理
            },
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: _isLoading
                ? Center(
                    child: Column(
                      children: [
                        Image.asset('assets/images/nowloading.gif'),
                        const Text('英文とその音声を生成なうです…')
                      ],
                    )
                )
                : Container(
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
    );
  }
}
