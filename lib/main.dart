import 'dart:async';

import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eşleştirme Oyunu',
      theme: ThemeData.dark(),
      home: Home(),
    );
  }
}

int level = 6;

class Home extends StatefulWidget {
  int size = 6;

  Home({this.size = 6});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<GlobalKey<FlipCardState>> cardStateKeys = [];
  List<bool> cardFlips = [];
  List<String> data = [];
  int previousIndex = -1;
  bool flip = false;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.size; i++) {
      cardStateKeys.add(GlobalKey<FlipCardState>());
      cardFlips.add(true);
    }
    for (var i = 0; i < widget.size ~/ 2; i++) {
      data.add(i.toString());
    }
    for (var i = 0; i < widget.size ~/ 2; i++) {
      data.add(i.toString());
    }
    data.shuffle();

    Future.delayed(const Duration(seconds: 1),(){
      setState(() {
        for (var i = 0; i < widget.size; i++) {
          cardStateKeys[i].currentState!.controller!.forward();
        }
      });
    });

    Future.delayed(const Duration(seconds: 2),(){
      setState(() {
        for (var i = 0; i < widget.size; i++) {
          cardStateKeys[i].currentState!.controller!.reverse();
        }
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Eşleştirme Oyunu')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Theme(
                data: ThemeData.dark(),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) => FlipCard(
                      key: cardStateKeys[index],
                      onFlip: () {
                        if (!flip) {
                          flip = true;
                          previousIndex = index;
                        } else {
                          flip = false;
                          if (previousIndex != index) {
                            if (data[previousIndex] != data[index]) {
                              cardStateKeys[previousIndex]
                                  .currentState!
                                  .toggleCard();
                              previousIndex = index;
                            } else {
                              print("kart1 :" +
                                  index.toString() +
                                  "" +
                                  cardFlips[index].toString() +
                                  "kart 2 :" +
                                  previousIndex.toString() +
                                  "" +
                                  cardFlips[previousIndex].toString());
                              Future.delayed(Duration(milliseconds: 750), () {
                                setState(() {
                                  cardFlips[previousIndex] = false;
                                  cardFlips[index] = false;
                                });
                                if (cardFlips.every((t) => t == false)) {
                                  print("Won");
                                  showResult();
                                }
                              });
                            }
                          }
                        }
                      },
                      direction: FlipDirection.HORIZONTAL,
                      flipOnTouch: cardFlips[index],
                      front: Container(
                        margin: EdgeInsets.all(4.0),
                        color: Colors.deepOrange.withOpacity(0.3),
                      ),
                      back: Container(
                        margin: EdgeInsets.all(4.0),
                        color: Colors.deepOrange,
                        child: Center(
                          child: cardFlips[index] == false
                              ? Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.contain,
                                              image: AssetImage(
                                                'assets/image/correct.png',
                                              )))),
                                )
                              : Text(
                                  "${data[index]}",
                                  style: Theme.of(context).textTheme.display2,
                                ),
                        ),
                      ),
                    ),
                    itemCount: data.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Kazandınız!!!"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Home(
                   size: level,
                  ),
                ),
              );
              level *= 2;
            },
            child: Text("İleri"),
          ),
        ],
      ),
    );
  }
}
