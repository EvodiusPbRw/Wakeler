import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';


var user_data;
QuerySnapshot ds;

class HomePage extends StatefulWidget{
  HomePage(var data, QuerySnapshot dsx){
    user_data = data;
    ds = dsx;
  }
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  String idDocument;
  TextEditingController namaW = new TextEditingController();
  int count = ds == null? 0 : ds.docs.length;
  Duration initialtimer = new Duration();
  QuerySnapshot tempDS;

  //=====================================================Check Data Firestore==========================================================
  Future<void> checkData() async {
    await Firebase.initializeApp();
    await FirebaseFirestore.instance.collection("user_reg").get().then((value) {
      for(int i =0;i<value.size;i++){
        if(value.docs[i].data()['username'] == user_data['username']){
          idDocument = value.docs[i].id;
          FirebaseFirestore.instance.collection("user_reg").doc(value.docs[i].id).collection("user_data").orderBy('saveTime',descending: false).get().then((value_time) {
            ds = value_time;
          });
        }
      }
    });
  }

  //=============================================================Add Data FireStore===================================================
  Future<void> addData() async {
    await Firebase.initializeApp();
    await FirebaseFirestore.instance.collection("user_reg").get().then((value) {
      for(int i =0;i<value.size;i++){
        if(value.docs[i].data()['username'] == user_data['username']){
          FirebaseFirestore.instance.collection("user_reg").doc(value.docs[i].id).collection("user_data").doc().set({
            'nama_waktu' : namaW.text,
            'menit' : initialtimer.inMinutes,
            'detik' : initialtimer.inSeconds,
            'saveTime': DateTime.now(),
          });
        }
      }
    });
    checkData();
    Navigator.of(context).pop();

  }


  //===================================================Delete Data FireStore===============================================================
  Future<void> deleteData() async{
    FirebaseFirestore.instance.collection("user_reg").doc(idDocument).collection("user_data").get().then((value){
      for(int i = 0;i<ds.size;i++){
        value.docs[i].reference.delete();
      }
    });

  }


  //====================================================Display Popup Menu==============================================
  _showPopupMenu(){
    showMenu<String>(
      color: HexColor("#111111"),
      context: context,
      position: RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),      //position where you want to show the menu on screen
      items: [
        PopupMenuItem<String>(
            child: Container(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child:Text(
                      user_data['username'],
                      style: TextStyle(
                          fontFamily: 'Javanese Text',
                          color: Colors.white

                      ),
                  ),

                  )
                ],
              ),
            ), value: '1'),
        PopupMenuItem<String>(
            child: Container(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child:Text(
                      "Logout",
                      style: TextStyle(
                          fontFamily: 'Javanese Text',
                          color: Colors.white
                      ),
                    ),

                  )
                ],
              ),
            ), value: '2'),
      ],
      elevation: 8.0,
    )
        .then<void>((String itemSelected) {

      if (itemSelected == null) return;

      if(itemSelected == "1"){
        print(idDocument);
      }else if(itemSelected == "2"){
        Navigator.pop(context);
      }
    });
  }

  //=======================================================================Main Return========================================================
  Widget build(BuildContext context){
    List<Widget> children = new List.generate(count, (int i) => new InputWidget(i));
    return Scaffold(
      backgroundColor: HexColor("#111111"),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 30,
            ),

            //=================================================== Header ========================================
            SingleChildScrollView(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          width: 200,
                          child: Text(
                            'Wakeler',
                            style: TextStyle(
                              fontFamily: 'Javanese Text',
                              fontSize: 41,
                              color: const Color(0xff868686),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),


                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 4.0,
                          height: 46.0,
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          decoration: BoxDecoration(
                            color: const Color(0xff3c3c3c),
                            border: Border.all(width: 1.0, color: const Color(0xff707070)),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 15, 0),
                          child : Ink(
                            decoration: const ShapeDecoration(shape: CircleBorder(),color : Colors.pinkAccent),
                            child: IconButton(
                              onPressed: _showPopupMenu,
                              icon: Icon(Icons.person,color: Colors.white,),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),


            //================================================Space terhadap Body ===================================
            Container(
              height: 30,
            ),

            //======================================================== Body =======================================================
            Column(
              children: children,
            )


          ],
        ),
      ),

      //======================================================= 2 Button Floating in Bottom ================================================
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),

            //================================================== Button Delete ====================================================
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                heroTag: "btnDelete",
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.delete),
                  onPressed: () {
                    deleteData();
                    setState(() {
                      children = null;
                      count=0;
                    });
                  }),
            ),
          ),
          //==================================================== Add Button ================================================
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "btnAdd",
              backgroundColor: Colors.pinkAccent,
              child: Icon(Icons.add),
              onPressed: (){
                  showDialog(context: context,
                      builder: (context) {
                        //===========================================Display Dialog==============================================
                        return Dialog(
                          backgroundColor: HexColor("#111111"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            height: 350.0,
                            width: 360.0,
                            child: Column(
                              children: <Widget>[
                                //=========================================Header Dialog =======================================
                                Container(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Text(
                                      "Add Countdown",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontFamily: 'Javanese Text',
                                          color: Colors.white
                                      ),
                                    )
                                ),

                                Container(
                                  width: 200.0,
                                  height: 5.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff3c3c3c),
                                    border: Border.all(width: 1.0, color: const Color(0xff707070)),
                                  ),
                                ),

                                //===========================================Text Field============================================
                                Container(
                                  width: 250,
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  child: TextField(
                                    controller: namaW,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: new BorderSide(color: HexColor("#707070"),width: 3.0)
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: new BorderSide(color: HexColor("#707070"),width: 3.0)
                                      ),
                                      hintText: "Name Countdown",
                                      hintStyle: TextStyle(color: HexColor("#707070")),

                                    ),
                                  ),
                                ),

                                //========================================TimerPicker Button in Dialog =======================================
                                Container(
                                    width: 250,
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: SingleChildScrollView(
                                      child: FlatButton(
                                        color: Colors.pinkAccent,
                                        child: Text("Timer Picker",style: TextStyle(color: Colors.white),),
                                        onPressed: (){
                                            //================================Display Dialog from bottom =================================
                                            showModalBottomSheet(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                context: context,
                                                builder: (BuildContext context){
                                                  //=====================================Pick Time =====================================
                                                  return Container(
                                                    width: 250,
                                                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                                                    child: CupertinoTimerPicker(
                                                      mode: CupertinoTimerPickerMode.ms,
                                                      minuteInterval: 1,
                                                      secondInterval: 1,
                                                      initialTimerDuration: initialtimer,
                                                      onTimerDurationChanged: (Duration changedtimer) {
                                                        setState(() {
                                                          initialtimer = changedtimer;
                                                        });
                                                      },
                                                    ),
                                                  );
                                                }
                                            );
                                        },
                                      ),
                                    )
                                ),

                                //====================================== Add Button in Dialog ==============================
                                Container(
                                    padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                                    child: SingleChildScrollView(
                                      child: RaisedButton(
                                        color: Colors.pinkAccent,
                                        child: Text("Add",style: TextStyle(color: Colors.white),),
                                        onPressed: (){
                                          setState(() {
                                            addData();
                                            count++;
                                          });
                                        },
                                      ),
                                    )
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  );
              },
            ),
          ),
        ],
      )
    );
  }
}

//=========================================== Input Widget for List<Widget> Children ==============================//
class InputWidget extends StatefulWidget{
  final int index;

  InputWidget(this.index);
  State<StatefulWidget> createState() => InputWidgetState(index);
}


class InputWidgetState extends State<InputWidget>{

  final int index;

  InputWidgetState(this.index);

  bool stateStart = true;

  DateTime alert;

  String mp3Uri;

  AudioPlayer advancedPlayer;
  AudioCache audioCache;

  //============================================ Untuk ngejadiin 2 var nerima input audio dari path ==========================
  void initPlayer() {
    advancedPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: advancedPlayer, prefix: 'audio/');
  }

  //=========================================== Return Text dan Play Audio =======================================
  Widget playSound(BuildContext context,String path) {
    audioCache.play(path);
    return Container(
      padding: EdgeInsets.fromLTRB(0, 13, 0, 0),
      child: Column(
        children: [
          Text(
            "00:00",
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Javanese Text',
                fontSize: 19
            ),
          ),
        ],
      ),
    );
  }

  //========================================= Stop Sound / Music ===============================================
  Future<void> stopSound() async{
    advancedPlayer.stop();
    return ;
  }

  @override
  void initState() {
    initPlayer();
    super.initState();
    alert = DateTime.now().add(Duration(seconds: 10));
  }


  // ==================================================== Set Format Value Minute:Seconds ============================
  String getStringMS(){
    String tempS;
    ds.docs[index].data()['menit'].toString().length == 1?
       tempS = "0" + ds.docs[index].data()['menit'].toString()
        :
        tempS = ds.docs[index].data()['menit'].toString();

    ds.docs[index].data()['detik'].toString().length == 1?
        tempS = tempS + ":0" + ds.docs[index].data()['detik'].toString()
        :
        tempS = tempS + ":" +ds.docs[index].data()['detik'].toString();

    return tempS;
  }

  // ===================================================== Format untuk pengurangan MS ==============================
  String formatDuration(Duration d) {
    String f(int n) {
      return n.toString().padLeft(2, '0');
    }
    // We want to round up the remaining time to the nearest second
    d += Duration(microseconds: 999999);
    return "${f(d.inMinutes)}:${f(d.inSeconds%60)}";
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: TimerBuilder.scheduled([alert],
        builder: (context) {
          var now = DateTime.now();
          var reached =now.compareTo(alert)>=0;
          return Column (
            children: <Widget>[
              Container(
                height: 10,
              ),

              Container(
                width: 370.0,
                height: 78.0,
                child: Column(
                  children: <Widget>[
                    //=================================================Box Container jika sesuai ====================================
                    ds.size > index?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[

                        Container(
                          padding: EdgeInsets.fromLTRB(10, 13, 0, 0),
                          child: Text(
                            ds.docs[index].data()['nama_waktu'],
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Javanese Text',
                                fontSize: 19
                            ),
                          ),
                        ),

                        stateStart?
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 13, 0, 0),
                          child: Text(
                            getStringMS(),
                            style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Javanese Text',
                            fontSize: 19
                            ),
                          ),
                        )
                        :
                        !reached?
                        TimerBuilder.periodic(
                            Duration(seconds: 1),
                            alignment: Duration.zero,
                            builder:(context){
                              var now =DateTime.now();
                              var remaining = alert.difference(now);
                              return Container(
                                padding: EdgeInsets.fromLTRB(0, 13, 0, 0),
                                child: Text(
                                  formatDuration(remaining),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Javanese Text',
                                      fontSize: 19
                                  ),
                                ),
                              );
                            }
                        )
                        :
                        playSound(context,'x.mp3'),

                        stateStart?
                        SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 13, 10, 0),
                            child: RaisedButton(
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.transparent),
                              ),
                              child: Text(
                                "Start",
                                style: TextStyle(
                                  color : Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: (){
                                stateStart = !stateStart;
                                setState(() {
                                  alert = DateTime.now().add(Duration(minutes: ds.docs[index].data()['menit'],seconds: ds.docs[index].data()['detik']));
                                });
                              },
                            ),
                          ),
                        )
                        :
                        SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 13, 10, 0),
                            child: RaisedButton(
                              color: Colors.pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.transparent),
                              ),
                              child: Text(
                                "Reset",
                                style: TextStyle(
                                  color : Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: (){
                                stateStart = !stateStart;
                                stopSound();
                                setState(() {
                                  alert = DateTime.now().add(Duration(minutes: ds.docs[index].data()['menit'],seconds: ds.docs[index].data()['detik']));
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    )
                    :
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 13, 0, 0),
                      child: FadeAnimatedTextKit(
                        //duration: Duration(seconds: 5),
                        isRepeatingAnimation: true,
                        text: [
                          "Loading",
                          "Loading ...",
                        ],
                        textStyle: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Javanese Text',
                              fontSize: 20
                          ),
                      )
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color(0xff111111),
                  border: Border.all(width: 3.0, color: Colors.grey),
                ),
              ),

            ],
          );
        },
      ),
    );
  }
}