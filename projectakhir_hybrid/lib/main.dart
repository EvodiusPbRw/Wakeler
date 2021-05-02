import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomePage.dart';

TextEditingController id_in = TextEditingController();
TextEditingController password_in = TextEditingController();
bool stateSign_In = true;
bool stateSign_Up = false;
var tempNilai;
QuerySnapshot ds;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  Widget build(BuildContext context){
    return MaterialApp(
      routes: {
        '/' :(context) => _loginPage(),
      },
    );
  }
}

class _loginPage extends StatefulWidget{
  State<StatefulWidget> createState() => _loginPageState();
}


class _loginPageState extends State<_loginPage>{
  String hintSign;
  String hintSignPw;
  String btnSign;
  Color colorSignIn;
  Color colorSignUp;


  void setSign(){
      if(stateSign_In){
        hintSign = "Input Your Username";
        hintSignPw = "Input Your Password";
        btnSign = "Sign In";
        colorSignIn = Colors.white;
        colorSignUp = const Color(0xff868686);
      }else if(stateSign_Up){
        hintSign = "Register Your Username";
        hintSignPw = "Register Your Password";
        btnSign = "Sign Up";
        colorSignIn = const Color(0xff868686);
        colorSignUp = Colors.white;
      }
  }

  void userAdd() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.collection("user_reg").doc().setData({
      'username' : id_in.text,
      'password' : password_in.text,
    });

    id_in.text = '';
    password_in.text = '';

  }

  Future<void> seeData() async {
    await Firebase.initializeApp();
    tempNilai ='';
    FirebaseFirestore.instance.collection("user_reg").where('username', isEqualTo: id_in.text).where('password',isEqualTo: password_in.text).getDocuments().then(
            (value) {
              if(value.docs.isNotEmpty){
                tempNilai = value.documents[0].data();
                FirebaseFirestore.instance.collection("user_reg").doc(value.docs[0].id).collection("user_data").orderBy("saveTime",descending: false).get().then((value_waktu) {
                  ds = null;
                  ds = value_waktu;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(tempNilai,ds)));
                });
                id_in.text = '';
                password_in.text = '';
              }else{
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Login Failed"),
                        titleTextStyle: TextStyle(fontFamily: 'Javanese Test',color: Colors.white,fontSize: 20),
                        titlePadding: EdgeInsets.fromLTRB(85, 15, 15, 15),
                        content: Text("Username atau Password Salah"),
                        contentTextStyle: TextStyle(fontFamily: 'Javanese Test', color: Colors.white,fontSize: 17),
                        backgroundColor: HexColor("#111111"),
                        actions: [
                          RaisedButton(
                            child: Text("Ok"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
              }
            });
    print(tempNilai['username']);
  }

  Widget build(BuildContext context){
    setSign();
      return Scaffold(
        backgroundColor: HexColor("#111111"),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 50,
              ),
              SizedBox(
                width: 176.0,
                child: Align(
                  alignment: Alignment.center,
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
              ),

              Container(
                width: 231.0,
                height: 5.0,
                decoration: BoxDecoration(
                  color: const Color(0xff3c3c3c),
                  border: Border.all(width: 1.0, color: const Color(0xff707070),),
                ),
              ),

              SingleChildScrollView(
                child: new Stack(
                  children: <Widget>[
                    Positioned(
                      child: new SizedBox(
                        width: 176.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Set You Up',
                            style: TextStyle(
                              fontFamily: 'Javanese Text',
                              fontSize: 20,
                              color: const Color(0xff868686),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
              ),

              Container(
                height:60,
              ),

             SingleChildScrollView(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                  FlatButton(
                    onPressed: (){
                      stateSign_Up = !stateSign_Up;
                      stateSign_In = !stateSign_In;
                      setState(() {
                        setSign();
                      });
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontFamily: 'Javanese Text',
                        fontSize: 28,
                        color: colorSignIn,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Container(
                    width: 4.0,
                    height: 46.0,
                    decoration: BoxDecoration(
                      color: const Color(0xff3c3c3c),
                      border: Border.all(width: 1.0, color: const Color(0xff707070)),
                    ),
                  ),

                  FlatButton(
                      onPressed: (){
                        stateSign_Up = !stateSign_Up;
                        stateSign_In = !stateSign_In;
                        setState(() {
                          setSign();
                        });
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'Javanese Text',
                          fontSize: 28,
                          color: colorSignUp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ),

                  ],
                ),
             ),


              Container(
                height: 30,
              ),

              Container(
                child: TextField(
                  controller: id_in,
                  style: TextStyle(color: HexColor("#707070")),
                  decoration: InputDecoration(
                    hintText: hintSign,
                    hintStyle: TextStyle(color: HexColor("#707070")),
                    enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: HexColor("#707070"),width: 3.0)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: HexColor("#707070"),width: 3.0)
                    ),
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person,color : HexColor("#707070"),),
                    labelStyle: TextStyle(color: HexColor("#707070"),fontSize: 17),
                  ),
                ),
              ),

              Container(
                height: 10,
              ),
              Container(
                child: TextField(
                  obscureText: true,
                  controller: password_in,
                  style: TextStyle(color: HexColor("#707070")),
                  decoration: InputDecoration(
                    hintText: hintSignPw,
                    hintStyle: TextStyle(color: HexColor("#707070")),
                    enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: HexColor("#707070"),width: 3.0)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: HexColor("#707070"),width: 3.0)
                    ),
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock,color : HexColor("#707070"),),
                    labelStyle: TextStyle(color: HexColor("#707070"),fontSize: 17),
                  ),
                ),
              ),

              Container(
                height: 25,
              ),

              Container(
                color: Colors.pinkAccent,
                child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(60,15,60,15),
                  color:Colors.pinkAccent,
                  child: Text(
                      btnSign,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Javanese Test',
                          fontSize: 20,
                      )
                  ),

                  onPressed: (){
                    print(id_in);
                    print( stateSign_Up);
                    if(stateSign_Up){
                      userAdd();
                    }
                    if(stateSign_In){
                      seeData();
                    }
                  },
                ),
              ),

            ],
          ),
        )
      );
    }
}