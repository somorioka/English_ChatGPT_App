import 'package:flutter/material.dart';

import 'chat_api.dart';
import 'english_sentence.dart';

class TopPage extends StatefulWidget {
  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 25.0,
        title: const Text(
          '英文を生成する',
          style: TextStyle(
              fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note),
            onPressed: () {
              // アイコンボタンの処理
            },
          ),
        ],
        elevation: 0,
      ),
      body: MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  String _selectedLevel = '初級'; // デフォルトのレベル
  final Map<String, String> _levelMap = {
    '初級': 'A1',
    '中級': 'A2',
    '上級': 'B2',
    '最上級': 'B1',
  };

  final _formKey = GlobalKey<FormState>();
  String _difficulty = '初級';
  String _phrase = '';
  String _generatedText = ''; // 追加: APIからのレスポンスを格納
  bool _isLoading = false; // ローディング状態の管理
  final _themeController = TextEditingController(); // テーマ用のコントローラー
  final _phraseController = TextEditingController(); // フレーズ用のコントローラー、追加

  void _generatePrompt() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ResultPage(
        theme: _themeController.text,
        difficulty: _difficulty,
        phrase: _phrase,
      ),
    ));
  }

  void _showLevelDescription(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Wrap(
          children: <Widget>[
            ListTile(
              title: Text('レベルの基準'),
              subtitle: Text(
                '初級: 基本的な表現が理解できるレベル\n'
                '中級: 日常会話がスムーズに行えるレベル\n'
                '上級: 幅広いトピックでのコミュニケーションが可能\n'
                '最上級: ネイティブスピーカーに近い理解度',
                style: TextStyle(height: 1.5), // 行間を調整
              ),
            ),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: MyTextField(
                controller: _themeController, // 修正: コントローラーを渡す
                hintText: 'テーマを入力',
                labelText: '英文のテーマ *',
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 18),
              child: Wrap(
                spacing: 6.0, // 水平方向のスペース
                runSpacing: 2.0, // 垂直方向のスペース
                children: <String>[
                  'スポーツ',
                  '映画',
                  '恋愛',
                  '旅行',
                  '食文化',
                  '生物',
                  '世界史',
                  '哲学'
                ]
                    .map((String theme) => ElevatedButton(
                          onPressed: () {
                            // ボタンが押された時の処理
                            setState(() {
                              _themeController.text = theme; // テキストフィールドにテーマを設定
                            });
                          },
                          child: Text(theme),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color.fromARGB(255, 255, 255, 255),
                            backgroundColor:
                                Color.fromARGB(255, 161, 161, 161), // テキスト色
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // 角の丸さ
                            ),
                            elevation: 0, // 影の効果をなくす
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8), // パディング
                          ),
                        ))
                    .toList(),
              ),
            ),
            // SizedBox(
            //   height: 20.0,
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 22.0),
            //   child: Text(
            //     'レベル *',
            //     style: TextStyle(
            //       fontWeight: FontWeight.w600
            //     )),
            // ),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  labelText: 'レベルを選択',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0), // 角丸の設定
                    borderSide:
                        BorderSide(color: Colors.grey), // 通常時のボーダーカラーを灰色に設定
                  ),
                  focusedBorder: OutlineInputBorder(
                    // フォーカス時のボーダー設定
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(color: Colors.grey), // フォーカス時のボーダーカラーを灰色に設定
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8), // コンテンツのパディング調整
                ),
                isExpanded: true, // ドロップダウンの選択肢を中央に寄せる
                value: _selectedLevel,
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      // nullでないことを保証
                      // 選択されたレベルに基づいて_difficultyを設定
                      switch (newValue) {
                        case '初級':
                          _difficulty = 'A1';
                          break;
                        case '中級':
                          _difficulty = 'A2';
                          break;
                        case '上級':
                          _difficulty = 'B2';
                          break;
                        case '最上級':
                          _difficulty = 'B1';
                          break;
                        default:
                          _difficulty = '初級'; // デフォルト値を設定（任意）
                          break;
                      }
                      _selectedLevel = newValue; // 選択されたレベルを更新
                    }
                  });
                },
                items: <String>['初級', '中級', '上級', '最上級']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(child: Text(value)), // テキストを中央に寄せる
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Wrap(
                spacing: 8.0, // 水平方向のスペース
                runSpacing: 4.0, // 垂直方向のスペース
                children: ['初級', '中級', '上級', '最上級'].map((String level) {
                  return ChoiceChip(
                    label: Text(level),
                    selected: _selectedLevel == level,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedLevel = level;
                        _difficulty =
                            _levelMap[level] ?? 'A1'; // マップを使用して_difficultyを更新
                      });
                    },
                    selectedColor: Color.fromARGB(255, 11, 180, 115), // 選択された時の色
                    backgroundColor: Colors.grey, // 選択されていない時の色
                    labelStyle: TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextButton(
                child: Text(
                  'レベルに関して',
                  style: TextStyle(
                    color: Color.fromARGB(255, 11, 180, 115)
                  ),
                  ),
                onPressed: () {
                  _showLevelDescription(context);
                },
                ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: MyTextField(
                hintText: '単語・フレーズを入力',
                labelText: '含めたい単語・フレーズ',
                controller: _phraseController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _generatePrompt,
                  child: Text(
                    '送信',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 44, 44, 44),
                    minimumSize:
                        Size(double.infinity, 50), // 幅を最大にして、高さを50ピクセルに設定
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // 角の丸さを20ピクセルの半径で設定
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller; // 修正: コントローラーを受け取る

  MyTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller, // 修正: コントローラーを受け取る
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Color.fromARGB(255, 122, 122, 122)),
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          // 通常時のボーダー設定
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey, width: 1.0), // 通常時のボーダーカラー
        ),
        focusedBorder: OutlineInputBorder(
          // フォーカス時のボーダー設定
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
              color: Color.fromARGB(255, 62, 62, 62),
              width: 1.0), // フォーカス時のボーダーカラー
        ),
      ),
    );
  }
}