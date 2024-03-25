import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String _selectedLevel = 'レベル1'; // デフォルトのレベル
  final Map<String, String> _levelMap = {
    'レベル1': 'A1',
    'レベル2': 'A2',
    'レベル3': 'B2',
    'レベル4': 'B1',
    'レベル5': 'C1',
    'レベル6': 'C2'
  };

  final _formKey = GlobalKey<FormState>();
  String _difficulty = 'レベル1';
  String _phrase = '';
  final _themeController = TextEditingController(); // テーマ用のコントローラー
  // final _phraseController = TextEditingController(); // フレーズ用のコントローラー、追加

  void _generatePrompt() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ResultPage(
        theme: _themeController.text,
        difficulty: _difficulty,
        // phrase: _phrase,
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
            const ListTile(
              title: Text('レベルの基準'),
              subtitle: Text(
                'レベル1: 英検3級レベル (CEFR A1)\n'
                'レベル2: 英検準2級レベル (CEFR A2)\n'
                'レベル3: 英検2級レベル (CEFR B1)\n'
                'レベル4: 英検準1級レベル (CEFR B2)\n'
                'レベル5: 英検1級レベル (CEFR C1)\n'
                'レベル6: ネイティブスピーカーレベル (CEFR C2)\n',
                style: TextStyle(height: 1.5), // 行間を調整
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // ボタンを右端に配置
                children: [
                  TextButton(
                    onPressed: _launchURL,
                    child: Text('詳しくはコチラ'),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    },
  );
}

Future<void> _launchURL() async {
  const url = 'https://www.mext.go.jp/b_menu/shingi/chousa/koutou/091/gijiroku/__icsFiles/afieldfile/2018/07/27/1407616_003.pdf'; // 遷移させたい外部ページのURL
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: const [
                  Text(
                    'テーマを決める',
                    style: TextStyle(
                      color: Color.fromARGB(255, 73, 73, 73),
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Color.fromARGB(221, 255, 0, 123),
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: MyTextField(
                controller: _themeController, // 修正: コントローラーを渡す
                hintText: 'テーマを入力',
                labelText: '英文のテーマ',
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
            const SizedBox(
              height: 35,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                'レベルを選ぶ',
                style: TextStyle(
                  color: Color.fromARGB(255, 73, 73, 73),
                  fontWeight: FontWeight.bold
                ),
                ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Wrap(
                spacing: 8.0, // 水平方向のスペース
                runSpacing: 0.0, // 垂直方向のスペース
                children: ['レベル1', 'レベル2', 'レベル3', 'レベル4', 'レベル5', 'レベル6'].map((String level) {
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
                child: const Text(
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
            // Padding(
            //   padding: EdgeInsets.all(15.0),
            //   child: MyTextField(
            //     hintText: '単語・フレーズを入力',
            //     labelText: '含めたい単語・フレーズ',
            //     controller: _phraseController,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _themeController.text.isEmpty ? null : _generatePrompt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 44, 44, 44),
                    minimumSize:
                        Size(double.infinity, 50), // 幅を最大にして、高さを50ピクセルに設定
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // 角の丸さを20ピクセルの半径で設定
                    ),
                  ),
                  child: const Text(
                    '送信',
                    style: TextStyle(fontWeight: FontWeight.w900),
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