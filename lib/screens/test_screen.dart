import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  final numberOfQuestions;

  TestScreen({required this.numberOfQuestions});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int numberOfRemaining = 0;
  int numberOfCorrect = 0;
  int correctRate = 0;

  int questionLeft = 5;
  int questionRight = 5;
  String operator = "+";
  String answerString = "10";

  late Soundpool soundpool;
  int soundIdCorrect = 0;
  int soundIdIncCorrect = 0;

  bool isCalcButtonEnabled = false;
  bool isAnswerCheckButtonEnabled = false;
  bool isBackButtonEnabled = false;
  bool isCorrectIncorrectImageEnabled = false;
  bool isEndMessageEnabled = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    numberOfCorrect = 0;
    correctRate = 0;
    numberOfRemaining = widget.numberOfQuestions;
    initSounds();

    setQuestion();
  }

  void initSounds() async {
    try {
      soundpool = Soundpool.fromOptions();
      soundIdCorrect = await loadSound("assets/sounds/sound_correct.mp3");
      soundIdIncCorrect = await loadSound("assets/sounds/sound_incorrect.mp3");
      setState(() {});
    } on IOException catch (error) {
      print("エラーの内容は$error");
    }
  }

  Future<int> loadSound(String soundPath) {
    return rootBundle.load(soundPath).then((value) => soundpool.load(value));
  }

  @override
  void dispose() {
    super.dispose();
    soundpool.release();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                //スコア表示
                _scorePart(),
                //問題表示部分
                _questionPart(),
                //電卓ボタン
                _calcButtons(),
                //答え合わせボタン
                _answerCheckButton(),
                //戻るボタン
                _backButton(),
              ],
            ),
            _correctIncorrectImage(),
            _endMessage(),
          ],
        ),
      ),
    );
  }

  Widget _scorePart() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Table(
        children: [
          TableRow(children: [
            Center(
              child: Text(
                "のこり問題数",
                style: TextStyle(fontSize: 10.0),
              ),
            ),
            Center(
              child: Text(
                "正解数",
                style: TextStyle(fontSize: 10.0),
              ),
            ),
            Center(
              child: Text(
                "正答率",
                style: TextStyle(fontSize: 10.0),
              ),
            ),
          ]),
          TableRow(children: [
            Center(
              child: Text(
                numberOfRemaining.toString(),
                style: TextStyle(fontSize: 10.0),
              ),
            ),
            Center(
              child: Text(
                numberOfCorrect.toString(),
                style: TextStyle(fontSize: 10.0),
              ),
            ),
            Center(
              child: Text(
                correctRate.toString(),
                style: TextStyle(fontSize: 10.0),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _questionPart() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 60.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                questionLeft.toString(),
                style: TextStyle(fontSize: 36.0),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                operator,
                style: TextStyle(fontSize: 30.0),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                questionRight.toString(),
                style: TextStyle(fontSize: 36.0),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "=",
                style: TextStyle(fontSize: 30.0),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                answerString,
                style: TextStyle(fontSize: 60.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcButtons() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 80.0),
        child: Table(
          children: [
            TableRow(children: [
              _calcButton(7.toString()),
              _calcButton(8.toString()),
              _calcButton(9.toString())
            ]),
            TableRow(children: [
              _calcButton(4.toString()),
              _calcButton(5.toString()),
              _calcButton(6.toString())
            ]),
            TableRow(children: [
              _calcButton(1.toString()),
              _calcButton(2.toString()),
              _calcButton(3.toString())
            ]),
            TableRow(children: [
              _calcButton(0.toString()),
              _calcButton("-"),
              _calcButton("C")
            ]),
          ],
        ),
      ),
    );
  }

  Widget _calcButton(String numString) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        onPressed: isCalcButtonEnabled ? () => inputAnswer(numString) : null,
        child: Text(
          numString,
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }

  Widget _answerCheckButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isCalcButtonEnabled ? () => answerCheck() : null,
          child: Text(
            "答え合わせ",
            style: TextStyle(fontSize: 14.0),
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isBackButtonEnabled ? () => closeTestScreen() : null,
          child: Text(
            "もどる",
            style: TextStyle(fontSize: 14.0),
          ),
        ),
      ),
    );
  }

  Widget _correctIncorrectImage() {
    if (isCorrectIncorrectImageEnabled == true) {
      if (isCorrect) {
        return Center(child: Image.asset("assets/images/pic_correct.png"));
      }
      return Center(child: Image.asset("assets/images/pic_incorrect.png"));
    } else {
      return Container();
    }
  }

  Widget _endMessage() {
    if (isEndMessageEnabled) {
      return Center(
          child: Text(
        "テスト終了",
        style: TextStyle(fontSize: 60.0),
      ));
    } else {
      return Container();
    }
  }

  //TODO
  void setQuestion() {
    isCalcButtonEnabled = true;
    isAnswerCheckButtonEnabled = true;
    isBackButtonEnabled = false;
    isCorrectIncorrectImageEnabled = false;
    isEndMessageEnabled = false;
    isCorrect = false;
    answerString = "";

    Random random = Random();
    questionLeft = random.nextInt(100) + 1;
    questionRight = random.nextInt(100) + 1;

    if (random.nextInt(2) + 1 == 1) {
      operator = "+";
    } else {
      operator = "-";
    }

    setState(() {});
  }

  inputAnswer(String numString) {
    setState(() {
      if (numString == "C") {
        answerString = "";
        return;
      }
      if (numString == "-") {
        if (answerString == "") {
          answerString = "-";
          return;
        }
      }
      if (numString == "0") {
        if (answerString != "0" && answerString != "-") {
          answerString = answerString + numString;
        }
        return;
      }
      if (answerString == "0") {
        answerString = numString;
        return;
      }

      answerString = answerString + numString;
    });
  }

  answerCheck() {
    if (answerString == "" || answerString == "-") {
      return;
    }

    isCalcButtonEnabled = false;
    isAnswerCheckButtonEnabled = false;
    isBackButtonEnabled = false;
    isCorrectIncorrectImageEnabled = true;
    isEndMessageEnabled = false;

    numberOfRemaining -= 1;

    var myAnswer = int.parse(answerString).toInt();

    var realAnswer = 0;
    if (operator == "+") {
      realAnswer = questionLeft + questionRight;
    } else {
      realAnswer = questionLeft - questionRight;
    }

    if (myAnswer == realAnswer) {
      isCorrect = true;
      soundpool.play(soundIdCorrect);
      numberOfCorrect += 1;
    } else {
      isCorrect = false;
      soundpool.play(soundIdIncCorrect);
    }
    correctRate =
        ((numberOfCorrect / (widget.numberOfQuestions - numberOfRemaining)) *
                100)
            .toInt();

    if (numberOfRemaining == 0) {
      //残り問題数がないとき
      isCalcButtonEnabled = false;
      isAnswerCheckButtonEnabled = false;
      isBackButtonEnabled = true;
      isCorrectIncorrectImageEnabled = true;
      isEndMessageEnabled = true;
    } else {
      //残り問題があるとき
      Timer(Duration(seconds: 1), () => setQuestion());
    }

    setState(() {});
  }

  closeTestScreen() {
    Navigator.pop(context);
  }
}
