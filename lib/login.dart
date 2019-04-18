import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moneyv3/home.dart';
import 'package:moneyv3/models/model_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  ModelLogin modellogin = ModelLogin();
  bool loading = false;
  Dio dio = new Dio();

  Future loadlistpayment() async {
    Response response = await dio.get(
        'http://dev.cyberia.la/testda/api/web/index.php?r=api/listpayment1');
    if (response.statusCode == 200) {
     // print(response.data);
      for (var item in response.data) {
        var type_id;
        var user_idq;
        if (int.parse(item['user_id']) == 3) {
          user_idq = 'NGUsGMM3Ww8BAVIiRLyC';
        } else {
          user_idq = 'zkw0BdSqCQNFAC81WJYJ';
        }
        if (int.parse(item['type_pay_id']) == 1) {
          type_id = "i4fHXCWznQ0b9fQgGXNp";
        } else if (int.parse(item['type_pay_id']) == 2) {
          type_id = '5IoklGE0SYsrLmXwx0jv';
        } else if (int.parse(item['type_pay_id']) == 3) {
          type_id = "dh1DmdXnGAhh8NpXLdNw";
        } else if (int.parse(item['type_pay_id']) == 11) {
          type_id = "xrvB5tMfkNEk9HMLFki3";
        } else if (int.parse(item['type_pay_id']) == 5) {
          type_id = 'YoZLNbfPzmxAv0OFNgb2';
        } else if (int.parse(item['type_pay_id']) == 6) {
          type_id = 'FLi0mGZOhWuZPWYmAB2v';
        } else if (int.parse(item['type_pay_id']) == 7) {
          type_id = "6LzqlhaJPOlF9m212Bda";
        } else if (int.parse(item['type_pay_id']) == 8) {
          type_id = "s2yBSRE5pR6Kin0bhSgg";
        } else if (int.parse(item['type_pay_id']) == 10) {
          type_id = "o4NJwitJL2AHo51Tx7Ev";
        } else {
          type_id = "neYHqCJgTnVEQOnLunYV";
        }
       var y = item['date'].substring(0,item['date'].length - 6);
       var m = item['date'].substring(5,item['date'].length - 3);
       var d = item['date'].substring(8,item['date'].length - 0);
       
       var t=d+'-'+m+'-'+y;
       int sort=int.parse(y+''+m+''+d);
    Firestore.instance.collection("payment").add({
      'amount': int.parse(item['amount']),
      'date': t,
      'description': item['description'],
      'type_pay_id':type_id,
      'user': user_idq,
      'sort':sort,
    });
      //  print(type_id);
      }
    }
  }


Future loadlistrecieved() async {
    Response response = await dio.get(
        'http://dev.cyberia.la/testda/api/web/index.php?r=api/listrecive1');
    if (response.statusCode == 200) {
     // print(response.data);
      for (var item in response.data) {
        var type_id;
        var user_idq;
        if (int.parse(item['user_id']) == 3) {
          user_idq = 'NGUsGMM3Ww8BAVIiRLyC';
        } else {
          user_idq = 'zkw0BdSqCQNFAC81WJYJ';
        }
        if (int.parse(item['tye_receive_id']) == 1) {
          type_id = "0qT55J6Df87hLPxy0el2";
        } else if (int.parse(item['tye_receive_id']) == 3) {
          type_id = "ZON9Ls4T9cTxJiXeP42p";
        } else {
          type_id = "cTieazoL1qlnSahWI1Pg";
        }
       var y = item['date'].substring(0,item['date'].length - 6);
       var m = item['date'].substring(5,item['date'].length - 3);
       var d = item['date'].substring(8,item['date'].length - 0);
       
       var t=d+'-'+m+'-'+y;
       int sort=int.parse(y+''+m+''+d);
    Firestore.instance.collection("recieved").add({
      'amount': int.parse(item['amount']),
      'date': t,
      'description': item['description'],
      'tye_receive_id':type_id,
      'user_id': user_idq,
      'sort':sort,
    });
      //  print(type_id);
      }
    }
  }

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
          prefs.setString('photo', talk['photo']);
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
        title: Center(child: Text("ລະ​ບົບ​ເກັບ​ກຳ​ເງີນ")),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(10),
          child: ListView(children: <Widget>[
            Column(
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
                /*RaisedButton.icon(
                  icon: Icon(
                    Icons.lock_open,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Loading',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  key: null,
                  onPressed: () {
                    //loadlistrecieved();
                  },
                  color: Colors.red,
                ),*/
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
