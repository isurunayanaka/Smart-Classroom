import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:littleclassroom/common_data/app_colors.dart';
import 'package:littleclassroom/common_data/app_strings.dart';
import 'package:littleclassroom/common_widgets/background_image.dart';
import 'package:littleclassroom/common_widgets/common_action_button.dart';
import 'package:littleclassroom/routes.dart';

class NumbersList{
  String numberName;
  String numberImage;
  NumbersList({required this.numberName, required this.numberImage});
}

class NumbersQuizScreen extends StatefulWidget {
  static const String routeName = '/numbers_quiz_page';
  const NumbersQuizScreen({Key? key}) : super(key: key);
  @override
  _NumbersQuizScreenState createState() => _NumbersQuizScreenState();
}

class _NumbersQuizScreenState extends State<NumbersQuizScreen> {
  late int level, score;
  late List<NumbersList> numbersList, quizAnswers, correctAnswer;
  late List<String> initialNumbersList, quizImages;
  late List<int> quizColors;
  late List<String> quizQuestion, quizTries;

  late FlutterTts flutterTts;
  late Random random;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    score = 0;
    level = 0;

    random = Random();
    flutterTts  = FlutterTts();
    flutterTts.setSpeechRate(0.3);
    flutterTts.setPitch(8.0);
    flutterTts.setVolume(1);
    flutterTts.setLanguage("en-GB");

    quizColors = List.filled(3,1,growable: true);
    initialNumbersList = ['1','2','3','4','5','6','7','8','9'];
    initialNumbersList.shuffle();
    quizImages = ['quiz_fish_blue.png','quiz_fish_orange.png','quiz_fish_purple.png','quiz_fish_red.png','quiz_fish_yellow.png'];
    quizAnswers = List.filled(2, NumbersList(numberImage: "", numberName: ""), growable: false);
    numbersList= List.filled(initialNumbersList.length, NumbersList(numberImage: "", numberName: ""), growable: true);

    for(int i=0; i<initialNumbersList.length; i++){
      numbersList[i] = NumbersList(numberName: initialNumbersList[i], numberImage: quizImages[random.nextInt(quizImages.length)]);
    }

    quizQuestion = List.filled(initialNumbersList.length, "",growable: true);
    quizTries = List.filled(initialNumbersList.length, "",growable: true);

    selectNumbersForQuiz(
        speakText: AppStrings.intro_quiz + AppStrings.numbers + " , " + AppStrings.select,
        questionNo: level,
        listOfNamesAndImages: numbersList
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  ///Select 3 Letters for Quiz
  void selectNumbersForQuiz({required String speakText, required int questionNo, required List<NumbersList> listOfNamesAndImages}) {
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
    quizAnswers = [listOfNamesAndImages[questionNo], listOfNamesAndImages[wrongAnswerOne], listOfNamesAndImages[wrongAnswerTwo]];

    do {
      quizColors[0] = random.nextInt(quizImages.length);
      quizColors[1] = random.nextInt(quizImages.length);
      quizColors[2] = random.nextInt(quizImages.length);
    } while (quizColors[0] == quizColors[1] || quizColors[0] == quizColors[2] || quizColors[1] == quizColors[2]);

    for(int i=0; i<quizAnswers.length; i++){
      quizAnswers[i].numberImage = quizImages[quizColors[i]];
    }

    quizAnswers.shuffle();
    flutterTts.speak(speakText + correctAnswer[0].numberName);
  }
  /// ////////////////////////////////////////

  ///Score showing dialog box
  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: const Text(AppStrings.ok),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.popAndPushNamed(context, Routes.numbers_page);
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
                Expanded(
                  child: ListView.builder(
                      itemCount: quizAnswers.length,
                      itemBuilder: (BuildContext context,int ind){
                        return Container(
                          width: size.width * 0.25,
                          height: size.height * 0.2,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/quiz/" + quizAnswers[ind].numberImage),
                                //fit: BoxFit.cover,
                              )
                          ),
                          child: TextButton(
                            onPressed: (){
                              flutterTts.stop();
                              ///Correct Answer
                              if(quizAnswers[ind].numberName == correctAnswer[0].numberName){
                                showDialog(
                                    context: context,
                                    builder: (BuildContext builderContext) {
                                      _timer = Timer(const Duration(seconds: 2), () {
                                        Navigator.of(context).pop();

                                        ///
                                        if(tries == 1){
                                          score = score + 1;
                                          quizQuestion[level] = correctAnswer[0].numberName;
                                          quizTries[level] = tries.toString();
                                        } else {
                                          score = score;
                                          quizQuestion[level] = correctAnswer[0].numberName;
                                          quizTries[level] = tries.toString();
                                        }
                                        level = level + 1;
                                        setState(() {
                                          if(level == initialNumbersList.length){
                                            flutterTts.stop();
                                            final FirebaseAuth auth = FirebaseAuth.instance;
                                            final String user = auth.currentUser!.uid;

                                            FirebaseFirestore.instance.collection(user).doc(AppStrings.numbers)
                                                .set({
                                              'Result': score.toString(),
                                              'QuestionCount': numbersList.length.toString(),
                                              'Question': quizQuestion,
                                              'Tries': quizTries,

                                            });

                                            flutterTts.speak(AppStrings.end_quiz);
                                            showAlertDialog(context);
                                          } else{
                                            flutterTts.stop();
                                            selectNumbersForQuiz(
                                                speakText: AppStrings.select,
                                                questionNo: level,
                                                listOfNamesAndImages: numbersList);
                                            print("Passed...... Level = " + level.toString()  + " Score = " + score.toString());
                                          }
                                        });
                                      });

                                      return AlertDialog(
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

                              ///Wrong Answer
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext builderContext) {
                                      _timer = Timer(const Duration(seconds: 2), () {
                                        Navigator.of(context).pop();
                                        flutterTts.speak(AppStrings.select + correctAnswer[0].numberName);
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
                            child: Text(
                              quizAnswers[ind].numberName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: size.height * 0.06,
                                  fontFamily: 'Muli',
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600
                              ),
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
              /*CommonActionButton(
                onPressed: (){
                  index = index - 1;
                  if(index < 0){
                    index = initialNumbersList.length - 1;
                  }
                  setState(() {
                    currentLowercaseLetter = initialNumbersList[index];
                    currentNumber = initialNumbersList[index];
                    spellPhonics(index);
                  });
                },
                icon: "assets/images/button_icons/button_previous.png",
              ),*/

              CommonActionButton(
                onPressed: (){
                  flutterTts.stop();
                  flutterTts.speak(AppStrings.select_number + correctAnswer[0].numberName);
                },
                icon: "assets/images/button_icons/button_re_play.png",
              ),

              /*CommonActionButton(
                onPressed: (){
                  index = index + 1;
                  if(index > initialNumbersList.length - 1){
                    index = 0;
                  }
                  setState(() {
                    currentLowercaseLetter = initialNumbersList[index];
                    currentNumber = initialNumbersList[index];
                    spellPhonics(index);
                  });

                },
                icon: "assets/images/button_icons/button_next.png",
              ),*/

            ],
          ),
        ],
      ),
    );

  }
}