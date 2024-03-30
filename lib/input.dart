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
  String _selectedLevel = 'A1'; // デフォルトのレベル

  final _formKey = GlobalKey<FormState>();
  String _difficulty = 'A1';
  // String _phrase = '';
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
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'CEFR（セファール）は、ヨーロッパで言語学習者の能力を示す共通基準です。文科省が英語の評価指標として使用しているなど、幅広く活用されています。'),
              ),
              const ListTile(
                title: Text('▪️ 英検との対応'),
                subtitle: Text(
                  'CEFR C2: ネイティブスピーカーレベル\n'
                  'CEFR C1: 英検1級レベル\n'
                  'CEFR B2: 英検準1級レベル\n'
                  'CEFR B1: 英検2級レベル\n'
                  'CEFR A2: 英検準2級レベル\n'
                  'CEFR A1: 英検3級レベル\n',
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
    const url =
        'https://www.mext.go.jp/b_menu/shingi/chousa/koutou/091/gijiroku/__icsFiles/afieldfile/2018/07/27/1407616_003.pdf'; // 遷移させたい外部ページのURL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    // ウィジェットの破棄時にコントローラーを破棄
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Row(
                  children: const [
                    Text(
                      'テーマを決める',
                      style: TextStyle(
                          color: Color.fromARGB(255, 73, 73, 73),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '*',
                      style: TextStyle(
                          color: Color.fromARGB(221, 255, 0, 123),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.0),
                child: TextFormField(
                  controller: _themeController,
                  decoration: InputDecoration(
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 122, 122, 122)),
                    labelText: 'テーマを入力',
                    hintText: '英文のテーマ',
                    border: OutlineInputBorder(
                      // 通常時のボーダー設定
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Colors.grey, width: 1.0), // 通常時のボーダーカラー
                    ),
                    focusedBorder: OutlineInputBorder(
                      // フォーカス時のボーダー設定
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 62, 62, 62),
                          width: 1.0), // フォーカス時のボーダーカラー
                    ),
                  ),
                  onChanged: (value) {
                    // テキストフィールドの値が変更されるたびに状態を更新
                    setState(() {});
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 18),
                child: Wrap(
                  spacing: 6.0, // 水平方向のスペース
                  runSpacing: 2.0, // 垂直方向のスペース
                  children: <String>[
                    'スポーツと科学',
                    '映画を作るには',
                    'エジプト旅行譚',
                    '未来の食文化',
                    '宇宙人と仲良くなるコツ',
                    'ジャンクフードの危険性',
                    'ナマケモノの生涯',
                    'AIと仕事',
                    '人生を変える名言',
                    '未知の言語の習得法',
                    '睡眠と記憶',
                  ]
                      .map((String theme) => ElevatedButton(
                            onPressed: () {
                              // ボタンが押された時の処理
                              setState(() {
                                _themeController.text =
                                    theme; // テキストフィールドにテーマを設定
                              });
                            },
                            child: Text(theme),
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  Color.fromARGB(255, 255, 255, 255),
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
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: const [
                    Text(
                      '難易度(CEFRレベル) を選ぶ',
                      style: TextStyle(
                          color: Color.fromARGB(255, 73, 73, 73),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(' 　(C2が最難)')
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 18.0), // 左右のパディングを均一に調整
                    child: Wrap(
                      spacing: 8.0, // 水平方向のスペース
                      runSpacing: 0.0, // 垂直方向のスペース
                      children: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
                          .map((String level) {
                        return ChoiceChip(
                          label: Text(level),
                          selected: _selectedLevel == level,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedLevel = level;
                              _difficulty = level;
                            });
                          },
                          selectedColor:
                              Color.fromARGB(255, 11, 180, 115), // 選択された時の色
                          backgroundColor: Colors.grey, // 選択されていない時の色
                          labelStyle: TextStyle(color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextButton(
                  child: const Text(
                    'CEFRレベルって何ぞや',
                    style: TextStyle(color: Color.fromARGB(255, 11, 180, 115)),
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
                    onPressed:
                        _themeController.text.isEmpty ? null : _generatePrompt,
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
      ),
    );
  }
}
