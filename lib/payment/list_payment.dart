import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyv3/home.dart';
import 'package:moneyv3/models/model_payment.dart';
import 'package:moneyv3/models/model_user.dart';

class ListPayment extends StatefulWidget {
  @override
  _ListPaymentState createState() => _ListPaymentState();
}

class _ListPaymentState extends State<ListPayment> {
  ModelPayment model_payment = ModelPayment();
  ModelUser model_user = ModelUser();

  void selectType(doc_id) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('type_pay').document(doc_id).get();
    if (mounted) {
      setState(() {
        model_payment.type_pay = snapshot['name'];
      });
    }
  }

  Future selectUser(user_id) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('user').document(user_id).get();
    //return snapshot['photo'];
    if (mounted) {
      setState(() {
        model_user.photo = snapshot['photo'];
      });
    }
  }

  Future selectbycondition() async {
    CollectionReference collectionReference =
        await Firestore.instance.collection('payment').reference();
    collectionReference.snapshots().listen((data) {
      data.documents.forEach((talk) {
        var docRef = Firestore.instance
            .collection('user')
            .document(talk['user'].toString());
        docRef.get().then((doc) {
          var data = doc.documentID + ":" + doc.data['photo'];
          model_payment.lsituser.add(data);
          print(model_payment.lsituser);

          setState(() {
            model_payment.lsituser = model_payment.lsituser;
          });
        });
        // print(talk.documentID + ': ' + talk['user']);
      });
    });

    print(model_payment.lsituser);
  }

  @override
  void initState() {
    super.initState();
   // selectbycondition();
  }
var list = await Future.wait();
  leading(user_id) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('bandnames').document(user_id).get();
     SizedBox(
        width: 60.0,
        height: 60.0,
        child: CircleAvatar(
          backgroundImage:
              NetworkImage((snapshot['photo']!= null) ? snapshot['photo']: ''),
        ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ລາຍ​ການ​ລາຍ​ຈ່າຍ​ທັງ​ໝົດ'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            }),
      ),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        alignment: Alignment.center,
        child: StreamBuilder(
            stream: Firestore.instance.collection('payment').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text('Laoding..........');
              return ListView.builder(
                  //itemExtent: 50,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    final formatter = new NumberFormat("#,###.00");
                    // selectType(snapshot.data.documents[index]['type_pay_id']
                    //    .toString());

                    // selectUser(snapshot.data.documents[index]['user']
                    //   .toString());
                    /*  var 'photo$index';
                    var docRef= Firestore.instance.collection('user').document(snapshot.data.documents[index]['user'].toString());
                    docRef.get().then((doc){
                      setState(() {
                         'photo$index'= doc.data['photo'];
                        });
                    });
                    print('photo$index');*/
                    //print(model_user.photo);
                    return ListTile(
                      leading: leading(
                          snapshot.data.documents[index]['user'].toString()),
                      title: Text(
                        model_payment.type_pay,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.black),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            formatter.format(int.parse(snapshot
                                    .data.documents[index]['amount']
                                    .toString())) +
                                ' ກີບ',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            snapshot.data.documents[index]['description'],
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 2,
                          ),
                          Text(
                            snapshot.data.documents[index]['date'],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider()
                        ],
                      ),
                      onTap: () {
                        //print(document.documentID);
                        //uploadPic();
                      },
                    );
                  });
            }),
      ),
      floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.red,
          child: new Icon(Icons.add_circle),
          onPressed: () {
            /*Navigator.push(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => FormPayment(null)));
                    */
            /* Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => FormPayment()));*/
          }),
    );
  }
}
