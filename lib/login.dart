import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moneyv3/home.dart';
import 'package:moneyv3/models/model_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  ModelLogin modellogin = ModelLogin();
  bool loading = false;
/*=================== function alert =============*/
  void alert(var detail) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              width: 100,
              height: 50,
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  Text(detail),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('ປິດ'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
  /*=========================== action Login =====================*/
  Future actionLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CollectionReference collectionReference =
        await Firestore.instance.collection('user').reference();
    collectionReference
        .where("username", isEqualTo: modellogin.username.text)
        .where("password", isEqualTo: modellogin.password.text)
        .where("status", isEqualTo: true)
        .snapshots()
        .listen((data) {
      if (data.documents.isEmpty) {
          alert("ຊື່​ເຂົ້າ​ລະ​ບົບ ຫຼື ລະ​ຫັດ​ຜ່ານ​ບໍ​ຖືກ​ຕ້ອງ");
      } else {
        data.documents.forEach((talk) {
          prefs.setString('token', talk.documentID);
          prefs.setString('type', talk['type']);
          prefs.setString('first_name', talk['first_name']);
          prefs.setString('last_name', talk['last_name']);
          //print(talk.documentID + ': ' + talk['first_name']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //title: Center(child: Text("ລະ​ບົບ​ເກັບ​ກຳ​ເງີນ")),
          ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: Image.network(
                  'https://image.shutterstock.com/z/stock-vector-blue-house-icon-in-vector-1244227747.jpg',
                  height: 50.0,
                  width: 50.0,
                ),
              ),
              TextFormField(
                controller: modellogin.username,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'ທ່ານ​ຕ​້ອງປ້ອນຊື່​ເຂົ້າ​ລະ​ບົບ';
                  }
                },
                decoration: InputDecoration(
                  hintText: "ຊື່​ເຂົ້າ​ລະ​ບົບ",
                  labelText: "ຊື່​ເຂົ້າ​ລະ​ບົບ",
                ),
              ),
              TextFormField(
                controller: modellogin.password,
                validator: (value) {
                  if (value.isEmpty) {
                    return "ທ່ານ​ຕ້ອງ​ປ້​ອນ​ລະ​ຫັດ​ຜ່ານ";
                  }
                },
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "​ປ້ອ​ນລະ​ຫັດ​ຜ່ານ",
                  labelText: "ລະ​ຫັດ​ຜ່ານ",
                ),
              ),
              SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: loading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : RaisedButton.icon(
                            icon: Icon(
                              Icons.lock_open,
                              color: Colors.white,
                            ),
                            label: Text(
                              'ເຂົ້າ​ລະ​ບົບ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            key: null,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                actionLogin();
                              }
                            },
                            color: Colors.red,
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
