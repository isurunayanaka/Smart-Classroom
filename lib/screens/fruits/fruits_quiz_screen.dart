import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_alert/arrays.dart';
import 'package:emoji_alert/emoji_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:littleclassroom/common_data/app_colors.dart';
import 'package:littleclassroom/common_data/app_strings.dart';
import 'package:littleclassroom/common_widgets/background_image.dart';
import 'package:littleclassroom/common_widgets/common_action_button.dart';
import 'package:littleclassroom/routes.dart';

class FruitsList{
  String fruitName;
  String fruitImage;
  FruitsList({required this.fruitName, required this.fruitImage});
}

class FruitsQuizScreen extends StatefulWidget {
  static const String routeName = '/fruits_quiz_page';
  const FruitsQuizScreen({Key? key}) : super(key: key);

  @override
  _FruitsQuizScreenState createState() => _FruitsQuizScreenState();
}

class _FruitsQuizScreenState extends State<FruitsQuizScreen> {
  late int level, score;
  late List<FruitsList> fruitsList, quizAnswers, correctAnswer;
  late List<String> quizQuestion, quizTries;

  late FlutterTts flutterTts;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    score = 0;
    level = 0;

    flutterTts  = FlutterTts();
    flutterTts.setSpeechRate(0.3);
    flutterTts.setPitch(8.0);
    flutterTts.setVolume(1);
    flutterTts.setLanguage("en-US");

    quizAnswers = List.filled(2, FruitsList(fruitImage: "", fruitName: ""), growable: false);
    fruitsList = [(FruitsList(fruitName: AppStrings.apple, fruitImage: "Fruits_apples.png")),
                    (FruitsList(fruitName: AppStrings.banana, fruitImage: "Fruits_banana.png")),
                    (FruitsList(fruitName: AppStrings.grapes, fruitImage: "Fruits_grapes.png")),
                    (FruitsList(fruitName: AppStrings.mango, fruitImage: "Fruits_mango.png")),
                    (FruitsList(fruitName: AppStrings.orange, fruitImage: "Fruits_orange.png")),
                    (FruitsList(fruitName: AppStrings.papaya, fruitImage: "Fruits_papaya.png")),
                    (FruitsList(fruitName: AppStrings.pineapple, fruitImage: "Fruits_pineapple.png")),
                    (FruitsList(fruitName: AppStrings.strawberry, fruitImage: "Fruits_strawberry.png"))];

    quizQuestion = List.filled(fruitsList.length, "",growable: true);
    quizTries = List.filled(fruitsList.length, "",growable: true);

    selectFruitsForQuiz(
        speakText: AppStrings.intro_quiz + AppStrings.fruits + " , " + AppStrings.select,
        questionNo: level,
        listOfNamesAndImages: fruitsList
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  ///Select 3 Letters for Quiz
  void selectFruitsForQuiz({required String speakText, required int questionNo, required List<FruitsList> listOfNamesAndImages}) {
    //print("Index = " + questionNo.toString());
    Random random = Random();
    int wrongAnswerOne, wrongAnswerTwo;

    do {
      wrongAnswerOne = random.nextInt(listOfNamesAndImages.length);
      wrongAnswerTwo = random.nextInt(listOfNamesAndImages.length);
    } while (wrongAnswerOne == questionNo || wrongAnswerTwo == questionNo || wrongAnswerOne == wrongAnswerTwo);

    //print("Random No 1: " + wrongAnswerOne.toString());
    //print("Random No 2 : " + wrongAnswerTwo.toString());

    correctAnswer = [listOfNamesAndImages[questionNo]];
    quizAnswers = [listOfNamesAndImages[questionNo], listOfNamesAndImages[wrongAnswerOne], listOfNamesAndImages[wrongAnswerTwo]];
    quizAnswers.shuffle();

    flutterTts.speak(speakText + correctAnswer[0].fruitName);
  }
  /// ////////////////////////////////////////

  ///Score showing dialog box
  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: const Text(AppStrings.ok),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.popAndPushNamed(context, Routes.fruits_home_page);
      },
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          side:BorderSide(color: AppColors.green, width: 5), //the outline color
          borderRadius: BorderRadius.all(Radius.circular(10))),
      title: const Text(
        AppStrings.congratulations,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30.0,
          color: AppColors.green,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 1.0,
              color: Colors.blue,
              offset: Offset(1.0, 2.0),
            ),
          ],
          decorationColor: AppColors.black,
          decorationStyle: TextDecorationStyle.double,
          letterSpacing: -1.0,
          wordSpacing: 5.0,
          fontFamily: 'Muli',
        ),
      ),
      content: const Text(
        AppStrings.you_have_successfully,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30.0,
          color: AppColors.darkBlue,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 1.0,
              color: Colors.blue,
              offset: Offset(1.0, 2.0),
            ),
          ],
          decorationColor: AppColors.black,
          decorationStyle: TextDecorationStyle.double,
          letterSpacing: -1.0,
          wordSpacing: 5.0,
          fontFamily: 'Muli',
        ),
      ),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  /// //////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    int tries = 1;

    return BackgroundImage(
      pageTitle: AppStrings.quiz1,
      topMargin: size.height * 0.02,
      width: size.width,
      height: size.height,
      isActiveAppBar: true,

      child: Column(
        children: <Widget>[
          Container(
            width: size.width * 0.8,
            height: size.height * 0.75,
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.01),
            padding: EdgeInsets.only(top: size.height * 0.015),
            decoration: const BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.center,
                image: AssetImage(
                  "assets/images/common_blackboard.png",
                ),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: size.height * 0.01,
                ),
                Text(
                  AppStrings.select_ + correctAnswer[0].fruitName ,
                  style: TextStyle(
                      fontSize: size.height * 0.03,
                      fontFamily: 'Muli',
                      fontWeight: FontWeight.w600
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: quizAnswers.length,
                      itemBuilder: (BuildContext context,int ind){
                        return FlatButton(
                          onPressed: (){
                            ///Answer Correct
                            if(quizAnswers[ind].fruitName == correctAnswer[0].fruitName){
                              showDialog(
                                  context: context,
                                  builder: (BuildContext builderContext) {
                                    _timer = Timer(const Duration(seconds: 2), () {
                                      Navigator.of(context).pop();

                                      ///
                                      if(tries == 1){
                                        score = score + 1;
                                        quizQuestion[level] = correctAnswer[0].fruitName;
                                        quizTries[level] = tries.toString();
                                      } else {
                                        score = score;
                                        quizQuestion[level] = correctAnswer[0].fruitName;
                                        quizTries[level] = tries.toString();
                                      }
                                      level = level + 1;
                                      setState(() {
                                        if(level == fruitsList.length){
                                          final FirebaseAuth auth = FirebaseAuth.instance;
                                          final String user = auth.currentUser!.uid;

                                          FirebaseFirestore.instance.collection(user).doc(AppStrings.fruits)
                                              .set({
                                            'Result': score.toString(),
                                            'QuestionCount': fruitsList.length.toString(),
                                            'Question': quizQuestion,
                                            'Tries': quizTries,

                                          });

                                          flutterTts.stop();
                                          flutterTts.speak(AppStrings.end_quiz);
                                          showAlertDialog(context);
                                        } else{
                                          flutterTts.stop();
                                          selectFruitsForQuiz(
                                              speakText: AppStrings.select,
                                              questionNo: level,
                                              listOfNamesAndImages: fruitsList);
                                          print("Passed...... Level = " + level.toString()  + " Score = " + score.toString());
                                        }
                                      });
                                    });

                                    return
                                      AlertDialog(
                                        backgroundColor: AppColors.white,
                                        title: const Text(
                                          AppStrings.very_good,
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Image.asset(
                                          "assets/images/quiz/skype-like.gif",
                                          width: size.width * 0.4,
                                          height: size.height * 0.3,
                                        ),
                                      );
                                  }
                              ).then((val){
                                if (_timer.isActive) {
                                  _timer.cancel();
                                }
                              });

                            ///Answer Wrong
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext builderContext) {
                                    _timer = Timer(const Duration(seconds: 2), () {
                                      Navigator.of(context).pop();
                                      flutterTts.speak(AppStrings.select + correctAnswer[0].fruitName);
                                    });

                                    return
                                      AlertDialog(
                                        backgroundColor: AppColors.white,
                                        contentPadding: const EdgeInsets.all(0),
                                        title: const Text(
                                          AppStrings.try_again,
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Image.asset(
                                          "assets/images/quiz/skype-speechless.gif",
                                          width: size.width * 0.4,
                                          height: size.height * 0.3,
                                        ),
                                    );
                                  }
                              ).then((val){
                                if (_timer.isActive) {
                                  _timer.cancel();
                                }
                              });
                              tries = tries + 1;
                              print("Failed..............");
                            }
                          },
                          child: Container(
                            width: size.width * 0.3,
                            height: size.height * 0.2,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/fruits/" + quizAnswers[ind].fruitImage),
                                  fit: BoxFit.cover,
                                  //fit: BoxFit.cover,
                                )
                            ),
                          ),
                        );
                      }),
                ),

              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CommonActionButton(
                onPressed: (){
                  flutterTts.speak(AppStrings.select + correctAnswer[0].fruitName);
                },
                icon: "assets/images/button_icons/button_re_play.png",
              ),
            ],
          ),
        ],
      ),
    );

  }
}